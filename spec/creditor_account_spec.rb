# encoding: utf-8
require 'spec_helper'

describe SEPA::CreditorAccount do
  it 'should initialize a new account' do
    expect(
      SEPA::CreditorAccount.new :name       => 'Gläubiger GmbH',
                                :bic        => 'BANKDEFFXXX',
                                :iban       => 'DE87200500001234567890',
                                :identifier => 'DE98ZZZ09999999999'
    ).to be_valid
  end

  describe :identifier do
    it 'should accept valid value' do
      [ 'DE98ZZZ09999999999' ].each do |value_value|
        expect(
          SEPA::CreditorAccount.new :identifier => value_value
        ).to have(:no).errors_on(:identifier)
      end
    end

    it 'should not accept invalid value' do
      [ '', 'invalid' ].each do |invalue_value|
        expect(
          SEPA::CreditorAccount.new :identifier => invalue_value
        ).to have_at_least(1).errors_on(:identifier)
      end
    end
  end
end
