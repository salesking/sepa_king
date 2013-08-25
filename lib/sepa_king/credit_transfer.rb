# encoding: utf-8

module SEPA
  class CreditTransfer < Message
    self.account_class = DebtorAccount

    def to_xml
      super

      builder = Builder::XmlMarkup.new :indent => 2
      builder.instruct!
      builder.Document :xmlns                => 'urn:iso:std:iso:20022:tech:xsd:pain.001.002.03',
                       :'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
                       :'xsi:schemaLocation' => 'urn:iso:std:iso:20022:tech:xsd:pain.001.002.03 pain.001.002.03.xsd' do
        builder.CstmrCdtTrfInitn do
          build_group_header(builder)
          build_payment_information(builder)
        end
      end
    end

  private
    def build_payment_information(builder)
      builder.PmtInf do
        builder.PmtInfId(payment_information_identification)
        builder.PmtMtd('TRF')
        builder.BtchBookg(true)
        builder.NbOfTxs(transactions.length)
        builder.CtrlSum('%.2f' % amount_total)
        builder.PmtTpInf do
          builder.SvcLvl do
            builder.Cd('SEPA')
          end
        end
        builder.ReqdExctnDt(Date.today.next.iso8601)
        builder.Dbtr do
          builder.Nm(account.name)
        end
        builder.DbtrAcct do
          builder.Id do
            builder.IBAN(account.iban)
          end
        end
        builder.DbtrAgt do
          builder.FinInstnId do
            builder.BIC(account.bic)
          end
        end
        builder.ChrgBr('SLEV')
        build_transactions(builder)
      end
    end

    def build_transactions(builder)
      transactions.each do |transaction|
        builder.CdtTrfTxInf do
          builder.PmtId do
            builder.EndToEndId(transaction.reference || 'NOTPROVIDED')
          end
          builder.Amt do
            builder.InstdAmt('%.2f' % transaction.amount, :Ccy => 'EUR')
          end
          builder.CdtrAgt do
            builder.FinInstnId do
              builder.BIC(transaction.bic)
            end
          end
          builder.Cdtr do
            builder.Nm(transaction.name)
          end
          builder.CdtrAcct do
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
end
