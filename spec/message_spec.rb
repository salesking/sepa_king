# encoding: utf-8
require 'spec_helper'

class DummyTransaction < SEPA::Transaction
  def valid?; true end
end

class DummyMessage < SEPA::Message
  self.account_class = SEPA::Account
  self.transaction_class = DummyTransaction
end

describe SEPA::Message do
  describe :amount_total do
    subject do
      message = DummyMessage.new
      message.add_transaction amount: 1.1
      message.add_transaction amount: 2.2
      message
    end

    it 'should sum up all transactions' do
      subject.amount_total.should == 3.3
    end

    it 'should sum up selected transactions' do
      subject.amount_total([subject.transactions[0]]).should == 1.1
    end
  end

  describe 'validation' do
    subject { DummyMessage.new }

    it 'should fail with invalid account' do
      subject.should_not be_valid
      subject.should have(1).error_on(:account)
    end

    it 'should fail without transactions' do
      subject.should_not be_valid
      subject.should have(1).error_on(:transactions)
    end
  end
end
