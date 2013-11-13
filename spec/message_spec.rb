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

  describe :message_identification do
    subject { DummyMessage.new }

    it 'should have a reader method' do
      subject.message_identification.should match(/SEPA-KING\/[0-9]+/)
    end

    it 'should have a writer method' do
      subject.message_identification = "MY_MESSAGE_ID/#{Time.now.to_i}"
      subject.message_identification.should match(/MY_MESSAGE_ID/)
    end
  end
end
