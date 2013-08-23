# encoding: utf-8
require 'spec_helper'

describe SEPA::Transaction do
  context 'Name' do
    it 'should accept valid value' do
      [ 'Manfred Mustermann III.', 'Zahlemann & Söhne GbR', 'X' * 70 ].each do |value_value|
        lambda {
          SEPA::CreditTransaction.new :name => value_value
        }.should_not raise_error
      end
    end

    it 'should not accept invalid value' do
      [ nil, '', 'X' * 71 ].each do |invalue_value|
        lambda {
          SEPA::CreditTransaction.new :name => invalue_value
        }.should raise_error(ArgumentError, /Name/)
      end
    end
  end

  context 'IBAN' do
    it 'should accept valid value' do
      [ 'DE21500500009876543210', 'PL61109010140000071219812874' ].each do |value_value|
        lambda {
          SEPA::CreditTransaction.new :iban => value_value
        }.should_not raise_error
      end
    end

    it 'should not accept invalid value' do
      [ nil, '', 'invalid' ].each do |invalue_value|
        lambda {
          SEPA::CreditTransaction.new :iban => invalue_value
        }.should raise_error(ArgumentError, /IBAN/)
      end
    end
  end

  context 'BIC' do
    it 'should accept valid value' do
      [ 'DEUTDEFF', 'DEUTDEFF500', 'SPUEDE2UXXX' ].each do |value_value|
        lambda {
          SEPA::CreditTransaction.new :bic => value_value
        }.should_not raise_error
      end
    end

    it 'should not accept invalid value' do
      [ nil, '', 'invalid' ].each do |invalue_value|
        lambda {
          SEPA::CreditTransaction.new :bic => invalue_value
        }.should raise_error(ArgumentError, /BIC/)
      end
    end
  end

  context 'Amount' do
    it 'should accept valid value' do
      [ 0.01, 1, 100, 100.00, 99.99, 1234567890.12, BigDecimal("10") ].each do |value_value|
        lambda {
          SEPA::CreditTransaction.new :amount => value_value
        }.should_not raise_error
      end
    end

    it 'should not accept invalid value' do
      [ nil, 0, -3, 1.23456 ].each do |invalue_value|
        lambda {
          SEPA::CreditTransaction.new :amount => invalue_value
        }.should raise_error(ArgumentError, /Amount/)
      end
    end
  end

  context 'Reference' do
    it 'should accept valid value' do
      [ 'ABC-1234/78.0', 'X' * 35 ].each do |value_value|
        lambda {
          SEPA::CreditTransaction.new :reference => value_value
        }.should_not raise_error
      end
    end

    it 'should not accept invalid value' do
      [ nil, '', 'X' * 36 ].each do |invalue_value|
        lambda {
          SEPA::CreditTransaction.new :reference => invalue_value
        }.should raise_error(ArgumentError, /Reference/)
      end
    end
  end
end
