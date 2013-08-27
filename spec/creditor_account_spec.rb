# encoding: utf-8
require 'spec_helper'

describe SEPA::CreditorAccount do
  it 'should initialize a new account' do
    expect(
      SEPA::CreditorAccount.new name:       'Gläubiger GmbH',
                                bic:        'BANKDEFFXXX',
                                iban:       'DE87200500001234567890',
                                identifier: 'DE98ZZZ09999999999'
    ).to be_valid
  end

  describe :identifier do
    it 'should accept valid value' do
      SEPA::CreditorAccount.should accept('DE98ZZZ09999999999', for: :identifier)
    end

    it 'should not accept invalid value' do
      SEPA::CreditorAccount.should_not accept('', 'invalid', for: :identifier)
    end
  end
end
