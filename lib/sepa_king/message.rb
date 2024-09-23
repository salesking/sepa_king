# encoding: utf-8

module SEPA
  PAIN_008_001_02 = 'pain.008.001.02'
  PAIN_008_001_08 = 'pain.008.001.08'
  PAIN_008_002_02 = 'pain.008.002.02'
  PAIN_008_003_02 = 'pain.008.003.02'
  PAIN_001_001_03 = 'pain.001.001.03'
  PAIN_001_001_09 = 'pain.001.001.09'
  PAIN_001_002_03 = 'pain.001.002.03'
  PAIN_001_003_03 = 'pain.001.003.03'
  PAIN_001_001_03_CH_02 = 'pain.001.001.03.ch.02'

  class Message
    include ActiveModel::Validations

    attr_reader :account, :grouped_transactions

    validates_presence_of :transactions
    validate do |record|
      record.errors.add(:account, record.account.errors.full_messages) unless record.account.valid?
    end

    class_attribute :account_class, :transaction_class, :xml_main_tag, :known_schemas

    def initialize(account_options={})
      @grouped_transactions = {}
      @account = account_class.new(account_options)
    end

    def add_transaction(options)
      transaction = transaction_class.new(options)
      raise ArgumentError.new(transaction.errors.full_messages.join("\n")) unless transaction.valid?
      @grouped_transactions[transaction_group(transaction)] ||= []
      @grouped_transactions[transaction_group(transaction)] << transaction
    end

    def transactions
      grouped_transactions.values.flatten
    end

    # @return [String] xml
    def to_xml(schema_name=self.known_schemas.first)
      raise SEPA::Error.new(errors.full_messages.join("\n")) unless valid?
      raise SEPA::Error.new("Incompatible with schema #{schema_name}!") unless schema_compatible?(schema_name)

      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |builder|
        builder.Document(xml_schema(schema_name)) do
          builder.__send__(xml_main_tag) do
            build_group_header(builder)
            build_payment_informations(builder, schema_name)
          end
        end
      end

      validate_final_document!(builder.doc, schema_name)
      builder.to_xml
    end

    def amount_total(selected_transactions=transactions)
      selected_transactions.inject(0) { |sum, t| sum + t.amount }
    end

    def schema_compatible?(schema_name)
      raise ArgumentError.new("Schema #{schema_name} is unknown!") unless self.known_schemas.include?(schema_name)

      case schema_name
        when PAIN_001_002_03, PAIN_008_002_02
          account.bic.present? && transactions.all? { |t| t.schema_compatible?(schema_name) }
        when PAIN_001_001_03, PAIN_001_001_09, PAIN_001_001_03_CH_02, PAIN_001_003_03, PAIN_008_003_02, PAIN_008_001_02, PAIN_008_001_08
          transactions.all? { |t| t.schema_compatible?(schema_name) }
      end
    end

    # Set unique identifer for the message
    def message_identification=(value)
      raise ArgumentError.new('message_identification must be a string!') unless value.is_a?(String)

      regex = /\A([A-Za-z0-9]|[\+|\?|\/|\-|\:|\(|\)|\.|\,|\'|\ ]){1,35}\z/
      raise ArgumentError.new("message_identification does not match #{regex}!") unless value.match?(regex)

      @message_identification = value
    end

    # Get unique identifer for the message (with fallback to a random string)
    def message_identification
      @message_identification ||= "SEPA-KING/#{SecureRandom.hex(11)}"
    end

    # Set creation date time for the message
    # p.s. Rabobank in the Netherlands only accepts the more restricted format [0-9]{4}[-][0-9]{2,2}[-][0-9]{2,2}[T][0-9]{2,2}[:][0-9]{2,2}[:][0-9]{2,2}
    def creation_date_time=(value)
      raise ArgumentError.new('creation_date_time must be a string!') unless value.is_a?(String)

      regex = /[0-9]{4}[-][0-9]{2,2}[-][0-9]{2,2}(?:\s|T)[0-9]{2,2}[:][0-9]{2,2}[:][0-9]{2,2}/
      raise ArgumentError.new("creation_date_time does not match #{regex}!") unless value.match?(regex)

      @creation_date_time = value
    end

    # Get creation date time for the message (with fallback to Time.now.iso8601)
    def creation_date_time
      @creation_date_time ||= Time.now.iso8601
    end

    # Returns the id of the batch to which the given transaction belongs
    # Identified based upon the reference of the transaction
    def batch_id(transaction_reference)
      grouped_transactions.each do |group, transactions|
        if transactions.select { |transaction| transaction.reference == transaction_reference }.any?
          return payment_information_identification(group)
        end
      end
    end

    def batches
      grouped_transactions.keys.collect { |group| payment_information_identification(group) }
    end

  private
    # @return {Hash<Symbol=>String>} xml schema information used in output xml
    def xml_schema(schema_name)
      return {
        :xmlns                => "urn:iso:std:iso:20022:tech:xsd:#{schema_name}",
        :'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
        :'xsi:schemaLocation' => "urn:iso:std:iso:20022:tech:xsd:#{schema_name} #{schema_name}.xsd"
      } unless schema_name == PAIN_001_001_03_CH_02

      {
        xmlns:                'http://www.six-interbank-clearing.com/de/pain.001.001.03.ch.02.xsd',
        'xmlns:xsi':          'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:schemaLocation': 'http://www.six-interbank-clearing.com/de/pain.001.001.03.ch.02.xsd  pain.001.001.03.ch.02.xsd'
      }
    end

    def build_group_header(builder)
      other_id = nil
      if account.respond_to?(:creditor_identifier)
        other_id = account.creditor_identifier
      end

      if account.organization_id != nil
        other_id = account.organization_id
      end

      builder.GrpHdr do
        builder.MsgId(message_identification)
        builder.CreDtTm(creation_date_time)
        builder.NbOfTxs(transactions.length)
        builder.CtrlSum('%.2f' % amount_total)
        builder.InitgPty do
          builder.Nm(account.name)
          builder.Id do
            builder.OrgId do
              builder.Othr do
                builder.Id(other_id)
              end
            end
          end if other_id
        end
      end
    end

    # Unique and consecutive identifier (used for the <PmntInf> blocks)
    def payment_information_identification(group)
      "#{message_identification}/#{grouped_transactions.keys.index(group)+1}"
    end

    # Returns a key to determine the group to which the transaction belongs
    def transaction_group(transaction)
      transaction
    end

    def validate_final_document!(document, schema_name)
      xsd = Nokogiri::XML::Schema(File.read(File.expand_path("../../lib/schema/#{schema_name}.xsd", __dir__)))
      errors = xsd.validate(document).map { |error| error.message }
      raise SEPA::Error.new("Incompatible with schema #{schema_name}: #{errors.join(', ')}") if errors.any?
    end
  end
end
