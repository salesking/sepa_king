# encoding: utf-8

module SEPA
  class DirectDebit < Message
    self.account_class = CreditorAccount
    self.transaction_class = DirectDebitTransaction
    self.xml_main_tag = 'CstmrDrctDbtInitn'

  private
    # @return {Hash<Symbol=>String>} xml schema information used in output xml
    def xml_schema
      { :xmlns                => 'urn:iso:std:iso:20022:tech:xsd:pain.008.002.02',
        :'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
        :'xsi:schemaLocation' => 'urn:iso:std:iso:20022:tech:xsd:pain.008.002.02 pain.008.002.02.xsd' }
    end

    def build_payment_informations(builder)
      transactions.group_by(&:requested_date).each do |requested_date, transactions|
        # All transactions with the same requested_date are placed into the same PmtInf block
        builder.PmtInf do
          builder.PmtInfId(payment_information_identification)
          builder.PmtMtd('DD')
          builder.NbOfTxs(transactions.length)
          builder.CtrlSum('%.2f' % amount_total)
          builder.PmtTpInf do
            builder.SvcLvl do
              builder.Cd('SEPA')
            end
            builder.LclInstrm do
              builder.Cd('CORE')
            end
            builder.SeqTp('OOFF')
          end
          builder.ReqdColltnDt((requested_date || Date.today.next).iso8601)
          builder.Cdtr do
            builder.Nm(account.name)
          end
          builder.CdtrAcct do
            builder.Id do
              builder.IBAN(account.iban)
            end
          end
          builder.CdtrAgt do
            builder.FinInstnId do
              builder.BIC(account.bic)
            end
          end
          builder.ChrgBr('SLEV')
          builder.CdtrSchmeId do
            builder.Id do
              builder.PrvtId do
                builder.Othr do
                  builder.Id(account.identifier)
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
          builder.EndToEndId(transaction.reference || 'NOTPROVIDED')
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
