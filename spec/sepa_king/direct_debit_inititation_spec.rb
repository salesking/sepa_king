require 'spec_helper'

describe SEPA::DirectDebitInitiation do
  it 'should create valid XML file' do
    ddi = SEPA::DirectDebitInitiation.new

    XML::Document.string(ddi.generate_xml).should validate_against('pain.008.002.02.xsd')
  end
end
