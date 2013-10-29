# encoding: utf-8
require 'spec_helper'

describe SEPA::Account do
  describe :new do
    it 'should not accept unknown keys' do
      expect {
        SEPA::Account.new foo: 'bar'
      }.to raise_error(NoMethodError)
    end
  end

  describe :name do
    it 'should accept valid value' do
      SEPA::Account.should accept('Gläubiger GmbH', 'Zahlemann & Söhne GbR', 'X' * 70, for: :name)
    end

    it 'should not accept invalid value' do
      SEPA::Account.should_not accept(nil, '', 'X' * 71, for: :name)
    end
  end

  describe :iban do
    it 'should accept valid value' do
      SEPA::Account.should accept('DE21500500009876543210', 'PL61109010140000071219812874', for: :iban)
    end

    it 'should not accept invalid value' do
      SEPA::Account.should_not accept(nil, '', 'invalid', for: :iban)
    end
  end

  describe :bic do
    it 'should accept valid value' do
      SEPA::Account.should accept('DEUTDEFF', 'DEUTDEFF500', 'SPUEDE2UXXX', for: :bic)
    end

    it 'should not accept invalid value' do
      SEPA::Account.should_not accept('', 'invalid', for: :bic)
    end
  end
end
