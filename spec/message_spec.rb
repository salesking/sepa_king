# encoding: utf-8
require 'spec_helper'

class DummyTransaction < SEPA::Transaction
  def valid?; true end
end

class DummyMessage < SEPA::Message
  self.account_class = Hash
  self.transaction_class = DummyTransaction
end

describe SEPA::Message do
  describe :amount_total do
    it 'should sum up transactions' do
      message = DummyMessage.new
      message.add_transaction :amount => 1.1
      message.add_transaction :amount => 2.2
      message.amount_total.should == 3.3
    end
  end
end
