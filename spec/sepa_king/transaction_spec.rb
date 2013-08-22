# encoding: utf-8
require 'spec_helper'

describe SEPA::Transaction do
  it "should not accept invalid IBAN" do
    lambda {
      SEPA::CreditTransaction.new :iban => 'invalid'
    }.should raise_error(ArgumentError, /IBAN/)
  end

  it "should not accept invalid BIC" do
    lambda {
      SEPA::CreditTransaction.new :bic => 'invalid'
    }.should raise_error(ArgumentError, /BIC/)
  end

  it "should not accept zero amount" do
    lambda {
      SEPA::CreditTransaction.new :amount => 0
    }.should raise_error(ArgumentError, /zero/)
  end

  it "should not accept negative amount" do
    lambda {
      SEPA::CreditTransaction.new :amount => -3
    }.should raise_error(ArgumentError, /negative/)
  end

  it "should not accept reference which is too long" do
    lambda {
      SEPA::CreditTransaction.new :reference => '123456789012345678901234567890123456'
    }.should raise_error(ArgumentError, /Reference/)
  end
end
