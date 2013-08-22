# encoding: utf-8

class SEPA::CreditTransferInitiation
  def generate_xml
    builder = Builder::XmlMarkup.new :indent => 2
    builder.instruct!
    builder.Document :xmlns                => 'urn:iso:std:iso:20022:tech:xsd:pain.001.002.03',
                     :'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
                     :'xsi:schemaLocation' => 'urn:iso:std:iso:20022:tech:xsd:pain.001.002.03 pain.001.002.03.xsd' do
      builder.CstmrCdtTrfInitn do
        builder.GrpHdr do
          builder.MsgId('Message-ID-4711')
          builder.CreDtTm(Time.now.iso8601)
          builder.NbOfTxs(1)
          builder.InitgPty do
            builder.Nm('Initiator Name')
          end
        end

        builder.PmtInf do
          builder.PmtInfId('Payment-Information-ID-4711')
          builder.PmtMtd('TRF')
          builder.BtchBookg(true)
          builder.NbOfTxs(1)
          builder.CtrlSum(6543.14)
          builder.PmtTpInf do
            builder.SvcLvl do
              builder.Cd('SEPA')
            end
          end
          builder.ReqdExctnDt(Date.new(2010,11,25).iso8601)
          builder.Dbtr do
            builder.Nm('Debtor Name')
          end
          builder.DbtrAcct do
            builder.Id do
              builder.IBAN('DE87200500001234567890')
            end
          end
          builder.DbtrAgt do
            builder.FinInstnId do
              builder.BIC('BANKDEFFXXX')
            end
          end
          builder.ChrgBr('SLEV')
          builder.CdtTrfTxInf do
            builder.PmtId do
              builder.EndToEndId('OriginatorID1234')
            end
            builder.Amt do
              builder.InstdAmt(6543.14, :Ccy => 'EUR')
            end
            builder.CdtrAgt do
              builder.FinInstnId do
                builder.BIC('SPUEDE2UXXX')
              end
            end
            builder.Cdtr do
              builder.Nm('Creditor Name')
            end
            builder.CdtrAcct do
              builder.Id do
                builder.IBAN('DE21500500009876543210')
              end
            end
            builder.RmtInf do
              builder.Ustrd('Unstructured Remittance Information')
            end
          end
        end
      end
    end
  end
end
