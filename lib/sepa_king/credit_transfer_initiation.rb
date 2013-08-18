# encoding: utf-8
module SEPA
  class CreditTransferInitiation < Base
    def generate_xml
      builder = Builder::XmlMarkup.new :indent => 2
      builder.instruct!
      builder.Document :xmlns                => 'urn:iso:std:iso:20022:tech:xsd:pain.001.002.03',
                       :'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
                       :'xsi:schemaLocation' => 'urn:iso:std:iso:20022:tech:xsd:pain.001.002.03 pain.001.002.03.xsd' do
        builder.CstmrCdtTrfInitn do
          self.to_xml builder
        end
      end
    end
  end
end
