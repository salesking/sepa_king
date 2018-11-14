# encoding: utf-8

module SEPA
  class DirectDebit < Message
    self.account_class = CreditorAccount
    self.transaction_class = DirectDebitTransaction
    self.xml_main_tag = 'CstmrDrctDbtInitn'
    self.known_schemas = [
      PAIN_008_003_02,
      PAIN_008_002_02,
      PAIN_008_001_02,
      PAIN_008_001_02_CH_03
    ]

    validate do |record|
      if record.transactions.map(&:local_instrument).uniq.size > 1
        errors.add(
          :base,
          'different local_instruments (e.g. CORE, COR1 AND B2B) must not be mixed in one message!'
        )
      end
    end

  private
    # Find groups of transactions which share the same values of some attributes
    def transaction_group(transaction)
      { requested_date:   transaction.requested_date,
        service_level:    transaction.service_level,
        local_instrument: transaction.local_instrument,
        sequence_type:    transaction.sequence_type,
        batch_booking:    transaction.batch_booking,
        account:          transaction.creditor_account || account
      }
    end

    def is_sps?(schema) # is Swiss Payment Standard
      schema == SEPA::PAIN_008_001_02_CH_03
    end

    def creditor_scheme_name(service_level)
      case service_level
      when 'CHDD' # PAIN_008_001_02_CH_03 only
        return 'CHDD'
      when 'CHTA' # PAIN_008_001_02_CH_03 only
        return 'CHLS'
      else
        return 'SEPA'
      end
    end

    # For IBANs from Switzerland or Liechtenstein the clearing system member id can be retrieved
    # as the 5th to 9th digit of the IBAN, which is the local bank code.
    def clearing_system_member_id_from_iban(iban)
      return iban.to_s[4..8].sub(/^0*/, '')
    end

    def build_payment_informations(builder, schema)
      # Build a PmtInf block for every group of transactions
      grouped_transactions.each do |group, transactions|
        builder.PmtInf do
          builder.PmtInfId(payment_information_identification(group))
          builder.PmtMtd('DD')
          if !is_sps?(schema) # Not allowed for swiss payment standard
            builder.BtchBookg(group[:batch_booking])
            builder.NbOfTxs(transactions.length)
            builder.CtrlSum('%.2f' % amount_total(transactions))
          end
          builder.PmtTpInf do
            builder.SvcLvl do # Prtry for SPS
              if is_sps?(schema)
                builder.Prtry(group[:service_level])
              else
                builder.Cd(group[:service_level])
              end
            end
            builder.LclInstrm do # Prtry for SPS
              if is_sps?(schema)
                builder.Prtry(group[:local_instrument])
              else
                builder.Cd(group[:local_instrument])
              end
            end
            builder.SeqTp(group[:sequence_type]) if !is_sps?(schema)
          end
          builder.ReqdColltnDt(group[:requested_date].iso8601)
          builder.Cdtr do
            builder.Nm(group[:account].name)
          end
          builder.CdtrAcct do
            builder.Id do
              builder.IBAN(group[:account].iban)
            end
          end
          builder.CdtrAgt do
            builder.FinInstnId do
              if group[:account].bic
                builder.BIC(group[:account].bic)
              elsif is_sps?(schema)
                builder.ClrSysMmbId do
                  builder.MmbId(clearing_system_member_id_from_iban(group[:account].iban))
                end
                if group[:account].isr_participant_number
                  builder.Othr do
                    builder.Id(group[:account].isr_participant_number)
                  end
                end
              else
                builder.Othr do
                  builder.Id('NOTPROVIDED')
                end
              end
            end
          end
          builder.ChrgBr('SLEV') if !is_sps?(schema)
          builder.CdtrSchmeId do
            builder.Id do
              builder.PrvtId do
                builder.Othr do
                  builder.Id(group[:account].creditor_identifier)
                  builder.SchmeNm do
                    builder.Prtry(creditor_scheme_name(group[:service_level]))
                  end
                end
              end
            end
          end

          transactions.each do |transaction|
            build_transaction(builder, transaction, schema)
          end
        end
      end
    end

    def build_amendment_informations(builder, transaction)
      builder.AmdmntInd(true)
      builder.AmdmntInfDtls do
        if transaction.original_debtor_account
          builder.OrgnlDbtrAcct do
            builder.Id do
              builder.IBAN(transaction.original_debtor_account)
            end
          end
        elsif transaction.same_mandate_new_debtor_agent
          builder.OrgnlDbtrAgt do
            builder.FinInstnId do
              builder.Othr do
                builder.Id('SMNDA')
              end
            end
          end
        end
        if transaction.original_creditor_account
          builder.OrgnlCdtrSchmeId do
            if transaction.original_creditor_account.name
              builder.Nm(transaction.original_creditor_account.name)
            end
            if transaction.original_creditor_account.creditor_identifier
              builder.Id do
                builder.PrvtId do
                  builder.Othr do
                    builder.Id(transaction.original_creditor_account.creditor_identifier)
                    builder.SchmeNm do
                      builder.Prtry('SEPA')
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    def build_transaction(builder, transaction, schema)
      builder.DrctDbtTxInf do
        builder.PmtId do
          if transaction.instruction.present?
            builder.InstrId(transaction.instruction)
          end
          builder.EndToEndId(transaction.reference)
        end
        builder.InstdAmt('%.2f' % transaction.amount, Ccy: transaction.currency)
        if !is_sps?(schema)
          builder.DrctDbtTx do
            builder.MndtRltdInf do
              builder.MndtId(transaction.mandate_id)
              builder.DtOfSgntr(transaction.mandate_date_of_signature.iso8601)
              build_amendment_informations(builder, transaction) if transaction.amendment_informations?
            end
          end
        end
        builder.DbtrAgt do
          builder.FinInstnId do
            if transaction.bic
              builder.BIC(transaction.bic)
            elsif is_sps?(schema)
              builder.ClrSysMmbId do
                builder.MmbId(clearing_system_member_id_from_iban(transaction.iban))
              end
            else
              builder.Othr do
                builder.Id('NOTPROVIDED')
              end
            end
          end
        end
        builder.Dbtr do
          builder.Nm(transaction.name)
          if transaction.debtor_address
            builder.PstlAdr do
              # Only set the fields that are actually provided.
              # StrtNm, BldgNb, PstCd, TwnNm provide a structured address
              # separated into its individual fields.
              # AdrLine provides the address in free format text.
              # Both are currently allowed and the actual preference depends on the bank.
              # Also the fields that are required legally may vary depending on the country
              # or change over time.
              if transaction.debtor_address.street_name
                builder.StrtNm transaction.debtor_address.street_name
              end

              if transaction.debtor_address.building_number
                builder.BldgNb transaction.debtor_address.building_number
              end

              if transaction.debtor_address.post_code
                builder.PstCd transaction.debtor_address.post_code
              end

              if transaction.debtor_address.town_name
                builder.TwnNm transaction.debtor_address.town_name
              end

              if transaction.debtor_address.country_code
                builder.Ctry transaction.debtor_address.country_code
              end

              if transaction.debtor_address.address_line1
                builder.AdrLine transaction.debtor_address.address_line1
              end

              if transaction.debtor_address.address_line2
                builder.AdrLine transaction.debtor_address.address_line2
              end
            end
          end
        end
        builder.DbtrAcct do
          builder.Id do
            builder.IBAN(transaction.iban)
          end
        end
        if transaction.remittance_information || transaction.structured_remittance_information
          builder.RmtInf do
            if transaction.remittance_information
              builder.Ustrd(transaction.remittance_information)
            end

            if transaction.structured_remittance_information
              builder.Strd do
                builder.CdtrRefInf do
                  builder.Tp do
                    builder.CdOrPrtry do
                      builder.Prtry(transaction.structured_remittance_information.proprietary)
                    end
                  end
                  builder.Ref(transaction.structured_remittance_information.reference)
                end
              end
            end
          end
        end
      end
    end
  end
end
