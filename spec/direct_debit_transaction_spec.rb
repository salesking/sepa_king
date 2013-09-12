# encoding: utf-8
require 'spec_helper'

describe SEPA::DirectDebitTransaction do
  it 'should initialize a new transaction' do
    expect(
      SEPA::DirectDebitTransaction.new name:                      'Zahlemann & Söhne Gbr',
                                       bic:                       'SPUEDE2UXXX',
                                       iban:                      'DE21500500009876543210',
                                       amount:                    39.99,
                                       reference:                 'XYZ-1234/123',
                                       remittance_information:    'Vielen Dank für Ihren Einkauf!',
                                       mandate_id:                'K-02-2011-12345',
                                       mandate_date_of_signature: Date.new(2011,1,25)
    ).to be_valid
  end

  context 'Mandate Date of Signature' do
    it 'should accept valid value' do
      SEPA::DirectDebitTransaction.should accept(Date.today, Date.today - 1, for: :mandate_date_of_signature)
    end

    it 'should not accept invalid value' do
      SEPA::DirectDebitTransaction.should_not accept(nil, '2010-12-01', Date.today + 1, for: :mandate_date_of_signature)
    end
  end

  context 'Mandate ID' do
    it 'should allow valid value' do
      SEPA::DirectDebitTransaction.should accept('XYZ-123', 'X' * 35, for: :mandate_id)
    end

    it 'should not allow invalid value' do
      SEPA::DirectDebitTransaction.should_not accept(nil, '', 'X' * 36, for: :mandate_id)
    end
  end

  context 'creditor_account' do
    it 'should accept valid value' do
      SEPA::DirectDebitTransaction.should accept({ name: 'a', iban: 'DE21500500009876543210', bic: 'SPUEDE2UXXX', creditor_identifier: 'DE98ZZZ09999999999'}, for: :creditor_account)
    end

    it 'should not accept valid value' do
      SEPA::DirectDebitTransaction.should_not accept({ name: 'a', iban: 'x', bic: 'y', creditor_identifier: 'b'}, for: :creditor_account)
    end
  end

end
