# encoding: utf-8

module SEPA
  class DirectDebit < Message
    self.account_class = CreditorAccount
    self.transaction_class = DirectDebitTransaction
    self.xml_main_tag = 'CstmrDrctDbtInitn'

    validate do |record|
      if record.transactions.map(&:local_instrument).uniq.size > 1
        errors.add(:base, 'CORE and B2B must not be mixed in one message!')
      end
    end

  private
    # @return {Hash<Symbol=>String>} xml schema information used in output xml
    def xml_schema
      { :xmlns                => 'urn:iso:std:iso:20022:tech:xsd:pain.008.002.02',
        :'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
        :'xsi:schemaLocation' => 'urn:iso:std:iso:20022:tech:xsd:pain.008.002.02 pain.008.002.02.xsd' }
    end

    # Find groups of transactions which share the same values of some attributes
    def grouped_transactions
      transactions.group_by do |transaction|
        { requested_date: transaction.requested_date,
          local_instrument: transaction.local_instrument,
          sequence_type: transaction.sequence_type,
          batch_booking: transaction.batch_booking,
          account_name: transaction_account(transaction).name,
          account_iban: transaction_account(transaction).iban,
          account_bic: transaction_account(transaction).bic,
          account_creditor_identifier:transaction_account(transaction).creditor_identifier
        }
      end
    end

    def transaction_account(transaction)
      transaction.account.present? ? transaction.account : account
    end

    def build_payment_informations(builder)
      # Build a PmtInf block for every group of transactions
      grouped_transactions.each do |group, transactions|
        builder.PmtInf do
          builder.PmtInfId(payment_information_identification)
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
            builder.Nm(group[:account_name])
          end
          builder.CdtrAcct do
            builder.Id do
              builder.IBAN(group[:account_iban])
            end
          end
          builder.CdtrAgt do
            builder.FinInstnId do
              builder.BIC(group[:account_bic])
            end
          end
          builder.ChrgBr('SLEV')
          builder.CdtrSchmeId do
            builder.Id do
              builder.PrvtId do
                builder.Othr do
                  builder.Id(group[:account_creditor_identifier])
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

    def build_transaction(builder, transaction)
      builder.DrctDbtTxInf do
        builder.PmtId do
          builder.EndToEndId(transaction.reference)
        end
        builder.InstdAmt('%.2f' % transaction.amount, Ccy: 'EUR')
        builder.DrctDbtTx do
          builder.MndtRltdInf do
            builder.MndtId(transaction.mandate_id)
            builder.DtOfSgntr(transaction.mandate_date_of_signature.iso8601)
          end
        end
        builder.DbtrAgt do
          builder.FinInstnId do
            builder.BIC(transaction.bic)
          end
        end
        builder.Dbtr do
          builder.Nm(transaction.name)
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
