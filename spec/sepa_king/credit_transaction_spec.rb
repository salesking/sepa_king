# encoding: utf-8
require 'spec_helper'

describe SEPA::CreditTransaction do
  it 'should initialize a new transaction' do
    lambda{
      SEPA::CreditTransaction.new :name                   => 'Telekomiker AG',
                                  :iban                   => 'DE37112589611964645802',
                                  :bic                    => 'PBNKDEFF370',
                                  :amount                 => 102.50,
                                  :reference              => 'XYZ-1234/123',
                                  :remittance_information => 'Rechnung 123 vom 22.08.2013'
    }.should_not raise_error
  end

  context 'Remittance information' do
    it 'should allow valid value' do
      [ '', 'Bonus', 'X' * 140 ].each do |valid_value|
        lambda {
          SEPA::CreditTransaction.new :remittance_information => valid_value
        }.should_not raise_error
      end
    end

    it 'should not allow invalid value' do
      [ nil, 'X' * 141 ].each do |invalid_value|
        lambda {
          SEPA::CreditTransaction.new :remittance_information => invalid_value
        }.should raise_error(ArgumentError, /Remittance/)
      end
    end
  end
end
