# encoding: utf-8

module SEPA
  class DirectDebit < Message
    self.account_class = CreditorAccount
    self.transaction_class = DirectDebitTransaction
    self.xml_main_tag = 'CstmrDrctDbtInitn'
    self.known_schemas = [ PAIN_008_003_02, PAIN_008_002_02, PAIN_008_001_02 ]

    validate do |record|
      if record.transactions.map(&:local_instrument).uniq.size > 1
        errors.add(:base, 'CORE, COR1 AND B2B must not be mixed in one message!')
      end
    end

  private
    # Find groups of transactions which share the same values of some attributes
    def transaction_group(transaction)
      { requested_date:   transaction.requested_date,
        local_instrument: transaction.local_instrument,
        sequence_type:    transaction.sequence_type,
        batch_booking:    transaction.batch_booking,
        account:          transaction.creditor_account || account
      }
    end

    def build_payment_informations(builder)
      # Build a PmtInf block for every group of transactions
      grouped_transactions.each do |group, transactions|
        builder.PmtInf do
          builder.PmtInfId(payment_information_identification(group))
          builder.PmtMtd('DD')
          builder.BtchBookg(group[:batch_booking])
          builder.NbOfTxs(transactions.length)
          builder.CtrlSum('%.2f' % amount_total(transactions))
          builder.PmtTpInf do
            builder.SvcLvl do
              builder.Cd('SEPA')
            end
            builder.LclInstrm do
              builder.Cd(group[:local_instrument])
            end
            builder.SeqTp(group[:sequence_type])
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
              else
                builder.Othr do
                  builder.Id('NOTPROVIDED')
                end
              end
            end
          end
          builder.ChrgBr('SLEV')
          builder.CdtrSchmeId do
            builder.Id do
              builder.PrvtId do
                builder.Othr do
                  builder.Id(group[:account].creditor_identifier)
                  builder.SchmeNm do
                    builder.Prtry('SEPA')
                  end
                end
              end
            end
          end

          transactions.each do |transaction|
            build_transaction(builder, transaction)
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
                  end
                end
              end
            end
          end
        end
      end
    end

    def build_transaction(builder, transaction)
      builder.DrctDbtTxInf do
        builder.PmtId do
          if transaction.instruction.present?
            builder.InstrId(transaction.instruction)
          end
          builder.EndToEndId(transaction.reference)
        end
        builder.InstdAmt('%.2f' % transaction.amount, Ccy: transaction.currency)
        builder.DrctDbtTx do
          builder.MndtRltdInf do
            builder.MndtId(transaction.mandate_id)
            builder.DtOfSgntr(transaction.mandate_date_of_signature.iso8601)
            build_amendment_informations(builder, transaction) if transaction.amendment_informations?
          end
        end
        builder.DbtrAgt do
          builder.FinInstnId do
            if transaction.bic
              builder.BIC(transaction.bic)
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
              builder.Ctry transaction.debtor_address.country_code
              builder.AdrLine transaction.debtor_address.address_line1
              builder.AdrLine transaction.debtor_address.address_line2
            end
          end
        end
        builder.DbtrAcct do
          builder.Id do
            builder.IBAN(transaction.iban)
          end
        end
        if transaction.remittance_information
          builder.RmtInf do
            builder.Ustrd(transaction.remittance_information)
          end
        end
      end
    end
  end
end
