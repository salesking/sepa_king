# encoding: utf-8
require 'spec_helper'

describe SEPA::Account do
  describe 'Initialization' do
    it 'should not accept unknown keys' do
      expect {
        SEPA::Account.new foo: 'bar'
      }.to raise_error(NoMethodError)
    end
  end

  describe :name do
    it 'should accept valid value' do
      [ 'Gläubiger GmbH', 'Zahlemann & Söhne GbR', 'X' * 70 ].each do |valid_value|
        expect(
          SEPA::Account.new name: valid_value
        ).to have(:no).errors_on(:name)
      end
    end

    it 'should not accept invalid value' do
      [ nil, '', 'X' * 71 ].each do |invalid_value|
        expect(
          SEPA::Account.new name: invalid_value
        ).to have_at_least(1).errors_on(:name)
      end
    end
  end

  describe :iban do
    it 'should accept valid value' do
      [ 'DE21500500009876543210', 'PL61109010140000071219812874' ].each do |valid_value|
        expect(
          SEPA::Account.new iban: valid_value
        ).to have(:no).errors_on(:iban)
      end
    end

    it 'should not accept invalid value' do
      [ nil, '', 'invalid' ].each do |invalid_value|
        expect(
          SEPA::Account.new iban: invalid_value
        ).to have_at_least(1).errors_on(:iban)
      end
    end
  end

  describe :bic do
    it 'should accept valid value' do
      [ 'DEUTDEFF', 'DEUTDEFF500', 'SPUEDE2UXXX' ].each do |valid_value|
        expect(
          SEPA::Account.new bic: valid_value
        ).to have(:no).errors_on(:bic)
      end
    end

    it 'should not accept invalid value' do
      [ nil, '', 'invalid' ].each do |invalid_value|
        expect(
          SEPA::Account.new bic: invalid_value
        ).to have_at_least(1).errors_on(:bic)
      end
    end
  end
end
