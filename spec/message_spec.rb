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

    describe 'getter' do
      it 'should return prefixed random hex string' do
        expect(subject.message_identification).to match(/SEPA-KING\/([a-f0-9]{2}){11}/)
      end
    end

    describe 'setter' do
      it 'should accept valid ID' do
        [ 'gid://myMoneyApp/Payment/15108', # for example, Rails Global ID could be a candidate
          Time.now.to_f.to_s                # or a time based string
        ].each do |valid_msgid|
          subject.message_identification = valid_msgid
          expect(subject.message_identification).to eq(valid_msgid)
        end
      end

      it 'should deny invalid string' do
        [ 'my_MESSAGE_ID/123', # contains underscore
          '',                  # blank string
          'üöäß',              # non-ASCII chars
          '1' * 36             # too long
        ].each do |arg|
          expect {
            subject.message_identification = arg
          }.to raise_error(ArgumentError)
        end
      end

      it 'should deny argument other than String' do
        [ 123,
          nil,
          :foo
        ].each do |arg|
          expect {
            subject.message_identification = arg
          }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
