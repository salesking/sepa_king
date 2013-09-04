# encoding: utf-8

module SEPA
  class Message
    attr_reader :account, :transactions
    class_attribute :account_class, :transaction_class, :xml_main_tag

    def initialize(account_options={})
      @transactions = []
      @account = account_class.new(account_options)
    end

    def add_transaction(options)
      transaction = transaction_class.new(options)
      raise ArgumentError.new(transaction.errors.full_messages.join("\n")) unless transaction.valid?
      @transactions << transaction
    end

    # @return [String] xml
    def to_xml
      raise RuntimeError.new(account.errors.full_messages.join("\n")) unless account.valid?

      builder = Builder::XmlMarkup.new indent: 2
      builder.instruct!
      builder.Document(xml_schema) do
        builder.__send__(xml_main_tag) do
          build_group_header(builder)
          build_payment_informations(builder)
        end
      end
    end

    def amount_total(selected_transactions=transactions)
      selected_transactions.inject(0) { |sum, t| sum + t.amount }
    end

  private
    def build_group_header(builder)
      builder.GrpHdr do
        builder.MsgId(message_identification)
        builder.CreDtTm(Time.now.iso8601)
        builder.NbOfTxs(transactions.length)
        builder.CtrlSum('%.2f' % amount_total)
        builder.InitgPty do
          builder.Nm(account.name)
        end
      end
    end

    # Unique identifer for the whole message
    def message_identification
      @message_identification ||= "SEPA-KING/#{Time.now.to_i}"
    end

    # Unique and consecutive identifier (used for the <PmntInf> blocks)
    def payment_information_identification
      @payment_information_counter ||= 0
      @payment_information_counter += 1
      "#{message_identification}/#{@payment_information_counter}"
    end
  end
end
