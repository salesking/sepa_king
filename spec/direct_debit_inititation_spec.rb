require 'spec_helper'

describe SEPA::DirectDebitInitiation do
  it 'should create XML file' do
    sepa = SEPA::DirectDebitInitiation.new
    expect(sepa.generate_xml).to match /XML/
    expect(sepa.generate_xml).to match /CstmrDrctDbtInitn/
  end
end
