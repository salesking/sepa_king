# encoding: utf-8

module SEPA
  class Message
    attr_reader :transactions

    def initialize(options)
      @transactions = []
    end

    def add_transaction(options)
      transaction = transaction_class.new(options)
      raise ArgumentError.new(transaction.errors.full_messages.join("\n")) unless transaction.valid?
      @transactions << transaction
    end

  private
    def transaction_class
      "#{self.class.name}Transaction".constantize
    end

    def build_group_header(builder)
      builder.GrpHdr do
        builder.MsgId(message_identification)
        builder.CreDtTm(Time.now.iso8601)
        builder.NbOfTxs(transactions.length)
        builder.CtrlSum(amount_total)
        builder.InitgPty do
          builder.Nm(account.name)
        end
      end
    end

    def amount_total
      transactions.inject(0) { |sum, t| sum + t.amount }
    end

    def message_identification
      "SEPA-KING/#{Time.now.iso8601}"
    end

    def payment_information_identification
      message_identification
    end
  end
end
