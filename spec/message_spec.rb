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
      expect(subject.amount_total).to eq(3.3)
    end

    it 'should sum up selected transactions' do
      expect(subject.amount_total([subject.transactions[0]])).to eq(1.1)
    end
  end

  describe 'validation' do
    subject { DummyMessage.new }

    it 'should fail with invalid account' do
      expect(subject).not_to be_valid
      expect(subject.errors_on(:account).size).to eq(2)
    end

    it 'should fail without transactions' do
      expect(subject).not_to be_valid
      expect(subject.errors_on(:transactions).size).to eq(1)
    end
  end

  describe :message_identification do
    subject { DummyMessage.new }

    it 'should have a reader method' do
      expect(subject.message_identification).to match(/SEPA-KING\/[0-9]+/)
    end

    it 'should have a writer method' do
      subject.message_identification = "MY_MESSAGE_ID/#{Time.now.to_i}"
      expect(subject.message_identification).to match(/MY_MESSAGE_ID/)
    end
  end
end
