require 'spec_helper'

describe SEPA::CreditTransferInitiation do
  it 'should create XML file' do
    sepa = SEPA::CreditTransferInitiation.new
    expect(sepa.generate_xml).to match /XML/
    expect(sepa.generate_xml).to match /CstmrCdtTrfInitn/
  end
end
