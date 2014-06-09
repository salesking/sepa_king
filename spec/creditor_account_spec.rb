# encoding: utf-8
require 'spec_helper'

describe SEPA::CreditorAccount do
  it 'should initialize a new account' do
    expect(
      SEPA::CreditorAccount.new name:                'Gläubiger GmbH',
                                bic:                 'BANKDEFFXXX',
                                iban:                'DE87200500001234567890',
                                creditor_identifier: 'DE98ZZZ09999999999'
    ).to be_valid
  end

  describe :creditor_identifier do
    it 'should accept valid value' do
      expect(SEPA::CreditorAccount).to accept('DE98ZZZ09999999999', 'AT12ZZZ00000000001', 'IT97ZZZA1B2C3D4E5F6G7H8', 'NL97ZZZ123456780001', 'FR12ZZZ123456', for: :creditor_identifier)
    end

    it 'should not accept invalid value' do
      expect(SEPA::CreditorAccount).not_to accept('', 'invalid', 'DE98ZZZ099999999990', 'DEAAAAAAAAAAAAAAAA', for: :creditor_identifier)
    end
  end
end
