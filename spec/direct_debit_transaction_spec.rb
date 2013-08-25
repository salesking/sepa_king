# encoding: utf-8
require 'spec_helper'

describe SEPA::DirectDebitTransaction do
  it 'should initialize a new transaction' do
    expect(
      SEPA::DirectDebitTransaction.new :name                      => 'Zahlemann & Söhne Gbr',
                                       :bic                       => 'SPUEDE2UXXX',
                                       :iban                      => 'DE21500500009876543210',
                                       :amount                    => 39.99,
                                       :reference                 => 'XYZ-1234/123',
                                       :remittance_information    => 'Vielen Dank für Ihren Einkauf!',
                                       :mandate_id                => 'K-02-2011-12345',
                                       :mandate_date_of_signature => Date.new(2011,1,25)
    ).to be_valid
  end

  context 'Mandate Date of Signature' do
    it 'should allow valid value' do
      [ Date.today, Date.today - 1 ].each do |valid_value|
        expect(
          SEPA::DirectDebitTransaction.new :mandate_date_of_signature => valid_value
        ).to have(:no).errors_on(:mandate_date_of_signature)
      end
    end

    it 'should not allow invalid value' do
      [ nil, '2010-12-01', Date.today + 1 ].each do |invalid_value|
        expect(
          SEPA::DirectDebitTransaction.new :mandate_date_of_signature => invalid_value
        ).to have_at_least(1).errors_on(:mandate_date_of_signature)
      end
    end
  end

  context 'Mandate ID' do
    it 'should allow valid value' do
      [ 'XYZ-123', 'X' * 35 ].each do |valid_value|
        expect(
          SEPA::DirectDebitTransaction.new :mandate_id => valid_value
        ).to have(:no).errors_on(:mandate_id)
      end
    end

    it 'should not allow invalid value' do
      [ nil, '', 'X' * 36 ].each do |invalid_value|
        expect(
          SEPA::DirectDebitTransaction.new :mandate_id => invalid_value
        ).to have_at_least(1).errors_on(:mandate_id)
      end
    end
  end
end
