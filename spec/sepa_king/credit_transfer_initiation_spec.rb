require 'spec_helper'

describe SEPA::CreditTransferInitiation do
  it 'should create valid XML file' do
    cti = SEPA::CreditTransferInitiation.new

    XML::Document.string(cti.to_xml).should validate_against('pain.001.002.03.xsd')
  end
end
