# encoding: utf-8
require 'spec_helper'

describe SEPA::Account do
  it 'should initialize a new account' do
    lambda{
      SEPA::Account.new :name       => 'Gläubiger GmbH',
                        :bic        => 'BANKDEFFXXX',
                        :iban       => 'DE87200500001234567890',
                        :identifier => 'DE98ZZZ09999999999'
    }.should_not raise_error
  end
end
