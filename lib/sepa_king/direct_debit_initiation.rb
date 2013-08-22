# encoding: utf-8

module SEPA
  class DirectDebitInitiation
    attr_reader :creditor, :transactions

    def initialize(creditor_options)
      @creditor = Account.new(creditor_options)
      @transactions = []
    end

    def add_transaction(options)
      @transactions << DebtTransaction.new(options)
    end

    def to_xml
      builder = Builder::XmlMarkup.new :indent => 2
      builder.instruct!
      builder.Document :xmlns                => 'urn:iso:std:iso:20022:tech:xsd:pain.008.002.02',
                       :'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
                       :'xsi:schemaLocation' => 'urn:iso:std:iso:20022:tech:xsd:pain.008.002.02 pain.008.002.02.xsd' do
        builder.CstmrDrctDbtInitn do
          builder.GrpHdr do
            builder.MsgId(message_identification)
            builder.CreDtTm(Time.now.iso8601)
            builder.NbOfTxs(transactions.length)
            builder.CtrlSum(amount_total)
            builder.InitgPty do
              builder.Nm(creditor.name)
            end
          end

          builder.PmtInf do
            builder.PmtInfId(payment_information_identification)
            builder.PmtMtd('DD')
            builder.PmtTpInf do
              builder.SvcLvl do
                builder.Cd('SEPA')
              end
              builder.LclInstrm do
                builder.Cd('CORE')
              end
              builder.SeqTp('OOFF')
            end
            builder.ReqdColltnDt(Date.today.iso8601)
            builder.Cdtr do
              builder.Nm(creditor.name)
            end
            builder.CdtrAcct do
              builder.Id do
                builder.IBAN(creditor.iban)
              end
            end
            builder.CdtrAgt do
              builder.FinInstnId do
                builder.BIC(creditor.bic)
              end
            end
            builder.ChrgBr('SLEV')
            builder.CdtrSchmeId do
              builder.Id do
                builder.PrvtId do
                  builder.Othr do
                    builder.Id(creditor.identifier)
                    builder.SchmeNm do
                      builder.Prtry('SEPA')
                    end
                  end
                end
              end
            end
            builder.DrctDbtTxInf do
              transactions.each do |transaction|
                builder.PmtId do
                  builder.EndToEndId('NOTPROVIDED')
                end
                builder.InstdAmt(transaction.amount, :Ccy => 'EUR')
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
              end
            end
          end
        end
      end
    end

  private
    def amount_total
      transactions.inject(0) { |sum, t| sum + t.amount }
    end

    def message_identification
      "SEPA-KING/#{Time.now.iso8601}"
    end

    def payment_information_identification
      message_identification
    end
  end
end
