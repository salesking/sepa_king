# encoding: utf-8
require 'spec_helper'

describe SEPA::CreditTransaction do
  it 'should initialize a new transaction' do
    lambda{
      SEPA::CreditTransaction.new :name                   => 'Telekomiker AG',
                                  :iban                   => 'DE37112589611964645802',
                                  :bic                    => 'PBNKDEFF370',
                                  :amount                 => 102.50,
                                  :remittance_information => 'Rechnung 123 vom 22.08.2013'
    }.should_not raise_error
  end
end
