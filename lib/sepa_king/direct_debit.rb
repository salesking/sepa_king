# encoding: utf-8

module SEPA
  class DirectDebit < Message
    attr_reader :account

    def initialize(account_options={})
      super
      @account = CreditorAccount.new(account_options)
    end

    def to_xml
      raise RuntimeError.new(@account.errors.full_messages.join("\n")) unless @account.valid?

      builder = Builder::XmlMarkup.new :indent => 2
      builder.instruct!
      builder.Document :xmlns                => 'urn:iso:std:iso:20022:tech:xsd:pain.008.002.02',
                       :'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
                       :'xsi:schemaLocation' => 'urn:iso:std:iso:20022:tech:xsd:pain.008.002.02 pain.008.002.02.xsd' do
        builder.CstmrDrctDbtInitn do
          build_group_header(builder)
          build_payment_information(builder)
        end
      end
    end

  private
    def build_payment_information(builder)
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
        builder.ReqdColltnDt(Date.today.next.iso8601)
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
        build_transactions(builder)
      end
    end

    def build_transactions(builder)
      transactions.each do |transaction|
        builder.DrctDbtTxInf do
          builder.PmtId do
            builder.EndToEndId(transaction.reference || 'NOTPROVIDED')
          end
          builder.InstdAmt('%.2f' % transaction.amount, :Ccy => 'EUR')
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
end
