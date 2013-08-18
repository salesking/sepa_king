# encoding: utf-8
module SEPA
  class DirectDebitInitiation < Base
    def generate_xml
      builder = Builder::XmlMarkup.new :indent => 2
      builder.instruct!
      builder.Document :xmlns                => 'urn:iso:std:iso:20022:tech:xsd:pain.008.002.02',
                       :'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
                       :'xsi:schemaLocation' => 'urn:iso:std:iso:20022:tech:xsd:pain.008.002.02 pain.008.002.02.xsd' do
        builder.CstmrDrctDbtInitn do
          self.to_xml builder
        end
      end
    end
  end
end
