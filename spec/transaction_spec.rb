# encoding: utf-8
require 'spec_helper'

describe SEPA::Transaction do
  context 'Name' do
    it 'should accept valid value' do
      [ 'Manfred Mustermann III.', 'Zahlemann & Söhne GbR', 'X' * 70 ].each do |value_value|
        expect(
          SEPA::Transaction.new name: value_value
        ).to have(:no).errors_on(:name)
      end
    end

    it 'should not accept invalid value' do
      [ nil, '', 'X' * 71 ].each do |invalue_value|
        expect(
          SEPA::Transaction.new name: invalue_value
        ).to have_at_least(1).errors_on(:name)
      end
    end
  end

  context 'IBAN' do
    it 'should accept valid value' do
      [ 'DE21500500009876543210', 'PL61109010140000071219812874' ].each do |value_value|
        expect(
          SEPA::Transaction.new iban: value_value
        ).to have(:no).errors_on(:iban)
      end
    end

    it 'should not accept invalid value' do
      [ nil, '', 'invalid' ].each do |invalue_value|
        expect(
          SEPA::Transaction.new iban: invalue_value
        ).to have_at_least(1).errors_on(:iban)
      end
    end
  end

  context 'BIC' do
    it 'should accept valid value' do
      [ 'DEUTDEFF', 'DEUTDEFF500', 'SPUEDE2UXXX' ].each do |value_value|
        expect(
          SEPA::Transaction.new bic: value_value
        ).to have(:no).errors_on(:bic)
      end
    end

    it 'should not accept invalid value' do
      [ nil, '', 'invalid' ].each do |invalue_value|
        expect(
          SEPA::Transaction.new bic: invalue_value
        ).to have_at_least(1).errors_on(:bic)
      end
    end
  end

  context 'Amount' do
    it 'should accept valid value' do
      [ 0.01, 1, 100, 100.00, 99.99, 1234567890.12, BigDecimal('10'), '42', '42.51', '42.512', 1.23456 ].each do |value_value|
        expect(
          SEPA::Transaction.new amount: value_value
        ).to have(:no).errors_on(:amount)
      end
    end

    it 'should not accept invalid value' do
      [ nil, 0, -3, 'xz' ].each do |invalue_value|
        expect(
          SEPA::Transaction.new amount: invalue_value
        ).to have_at_least(1).errors_on(:amount)
      end
    end
  end

  context 'Reference' do
    it 'should accept valid value' do
      [ nil, 'ABC-1234/78.0', 'X' * 35 ].each do |value_value|
        expect(
          SEPA::Transaction.new reference: value_value
        ).to have(:no).errors_on(:reference)
      end
    end

    it 'should not accept invalid value' do
      [ '', 'X' * 36 ].each do |invalid_value|
        expect(
          SEPA::Transaction.new reference: invalid_value
        ).to have_at_least(1).errors_on(:reference)
      end
    end
  end

  context 'Remittance information' do
    it 'should allow valid value' do
      [ nil, 'Bonus', 'X' * 140 ].each do |valid_value|
        expect(
          SEPA::Transaction.new remittance_information: valid_value
        ).to have(:no).errors_on(:remittance_information)
      end
    end

    it 'should not allow invalid value' do
      [ '', 'X' * 141 ].each do |invalid_value|
        expect(
          SEPA::Transaction.new remittance_information: invalid_value
        ).to have_at_least(1).errors_on(:remittance_information)
      end
    end
  end

  context 'Requested date' do
    it 'should allow valid value' do
      [ nil, Date.today.next, Date.today + 2 ].each do |valid_value|
        expect(
          SEPA::Transaction.new requested_date: valid_value
        ).to have(:no).errors_on(:requested_date)
      end
    end

    it 'should not allow invalid value' do
      [ Date.new(1995,12,21), Date.today - 1, Date.today ].each do |invalid_value|
        expect(
          SEPA::Transaction.new requested_date: invalid_value
        ).to have_at_least(1).errors_on(:requested_date)
      end
    end
  end
end
