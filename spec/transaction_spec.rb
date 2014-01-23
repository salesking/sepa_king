# encoding: utf-8
require 'spec_helper'

describe SEPA::Transaction do
  describe :new do
    it 'should have default for reference' do
      SEPA::Transaction.new.reference.should == 'NOTPROVIDED'
    end

    it 'should have default for requested_date' do
      SEPA::Transaction.new.requested_date.should == Date.today.next
    end

    it 'should have default for batch_booking' do
      SEPA::Transaction.new.batch_booking.should == true
    end
  end

  context 'Name' do
    it 'should accept valid value' do
      SEPA::Transaction.should accept('Manfred Mustermann III.', 'Zahlemann & Söhne GbR', 'X' * 70, for: :name)
    end

    it 'should not accept invalid value' do
      SEPA::Transaction.should_not accept(nil, '', 'X' * 71, for: :name)
    end
  end

  context 'IBAN' do
    it 'should accept valid value' do
      SEPA::Transaction.should accept('DE21500500009876543210', 'PL61109010140000071219812874', for: :iban)
    end

    it 'should not accept invalid value' do
      SEPA::Transaction.should_not accept(nil, '', 'invalid', for: :iban)
    end
  end

  context 'BIC' do
    it 'should accept valid value' do
      SEPA::Transaction.should accept('DEUTDEFF', 'DEUTDEFF500', 'SPUEDE2UXXX', for: :bic)
    end

    it 'should not accept invalid value' do
      SEPA::Transaction.should_not accept('', 'invalid', for: :bic)
    end
  end

  context 'Amount' do
    it 'should accept valid value' do
      SEPA::Transaction.should accept(0.01, 1, 100, 100.00, 99.99, 1234567890.12, BigDecimal('10'), '42', '42.51', '42.512', 1.23456, for: :amount)
    end

    it 'should not accept invalid value' do
      SEPA::Transaction.should_not accept(nil, 0, -3, 'xz', for: :amount)
    end
  end

  context 'Reference' do
    it 'should accept valid value' do
      SEPA::Transaction.should accept(nil, 'ABC-1234/78.0', 'X' * 35, for: :reference)
    end

    it 'should not accept invalid value' do
      SEPA::Transaction.should_not accept('', 'X' * 36, for: :amount)
    end
  end

  context 'Remittance information' do
    it 'should allow valid value' do
      SEPA::Transaction.should accept(nil, 'Bonus', 'X' * 140, for: :remittance_information)
    end

    it 'should not allow invalid value' do
      SEPA::Transaction.should_not accept('', 'X' * 141, for: :remittance_information)
    end
  end
end
