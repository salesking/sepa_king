# encoding: utf-8
require 'spec_helper'

describe SEPA::DebtTransaction do
  it 'should initialize a new transaction' do
    lambda{
      SEPA::DebtTransaction.new :name                      => 'Zahlemann & Söhne Gbr',
                                :iban                      => 'DE21500500009876543210',
                                :bic                       => 'SPUEDE2UXXX',
                                :amount                    => 39.99,
                                :mandate_id                => 'K-02-2011-12345',
                                :mandate_date_of_signature => Date.new(2011,01,25)
    }.should_not raise_error
  end
end
