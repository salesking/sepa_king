# encoding: utf-8

class SEPA::DirectDebitInitiation
  def generate_xml
    builder = Builder::XmlMarkup.new :indent => 2
    builder.instruct!
    builder.Document :xmlns                => 'urn:iso:std:iso:20022:tech:xsd:pain.008.002.02',
                     :'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
                     :'xsi:schemaLocation' => 'urn:iso:std:iso:20022:tech:xsd:pain.008.002.02 pain.008.002.02.xsd' do
      builder.CstmrDrctDbtInitn do
        builder.GrpHdr do
          builder.MsgId('Message-ID')
          builder.CreDtTm(Time.now.strftime("%Y-%m-%dT%H:%M:%S"))
          builder.NbOfTxs(1)
          builder.CtrlSum(6543.14)
          builder.InitgPty do
            builder.Nm('Initiator Name')
          end
        end

        builder.PmtInf do
          builder.PmtInfId('Payment-ID')
          builder.PmtMtd('DD')
          builder.PmtTpInf do
            builder.SvcLvl do
              builder.Cd('SEPA')
            end
            builder.LclInstrm do
              builder.Cd('CORE')
            end
            builder.SeqTp('FRST')
          end
          builder.ReqdColltnDt(Date.today.strftime("%Y-%m-%d"))
          builder.Cdtr do
            builder.Nm('Creditor Name')
          end
          builder.CdtrAcct do
            builder.Id do
              builder.IBAN('DE87200500001234567890')
            end
          end
          builder.CdtrAgt do
            builder.FinInstnId do
              builder.BIC('BANKDEFFXXX')
            end
          end
          builder.ChrgBr('SLEV')
          builder.CdtrSchmeId do
            builder.Id do
              builder.PrvtId do
                builder.Othr do
                  builder.Id('DE00ZZZ00099999999')
                  builder.SchmeNm do
                    builder.Prtry('SEPA')
                  end
                end
              end
            end
          end
          builder.DrctDbtTxInf do
            builder.PmtId do
              builder.EndToEndId('OriginatorID1235')
            end
            builder.InstdAmt('6543.14', :Ccy => 'EUR')
            builder.DrctDbtTx do
              builder.MndtRltdInf do
                builder.MndtId('Mandate-Id')
                builder.DtOfSgntr(Date.new(2010,11,20).strftime("%Y-%m-%d"))
              end
            end
            builder.DbtrAgt do
              builder.FinInstnId do
                builder.BIC('SPUEDE2UXXX')
              end
            end
            builder.Dbtr do
              builder.Nm('Debtor Name')
            end
            builder.DbtrAcct do
              builder.Id do
                builder.IBAN('DE21500500009876543210')
              end
            end
          end
        end
      end
    end
  end
end
