# frozen_string_literal: true

require_relative './message'

require 'digest/sha2'

module SEPA

  CONTAINER_NNN_001_02    = 'container.nnn.001.02'
  CONTAINER_NNN_001_GBIC4 = 'container.nnn.001.GBIC4'
  CONTAINER_NNN_001_04    = 'container.nnn.001.04'

  CONTAINER_TO_MESSAGE_MAPPING = {
    CONTAINER_NNN_001_02    => {
      SEPA::CreditTransfer => PAIN_001_001_03,
      SEPA::DirectDebit    => PAIN_008_001_02,
    },
    CONTAINER_NNN_001_GBIC4 => {
      SEPA::CreditTransfer => PAIN_001_001_09,
      SEPA::DirectDebit    => PAIN_008_001_08,
    },
    CONTAINER_NNN_001_04    => {
      SEPA::CreditTransfer => PAIN_001_001_09,
      SEPA::DirectDebit    => PAIN_008_001_08,
    },
  }.freeze

  class Container

    include ActiveModel::Validations
    extend Converter

    attr_reader :messages,
                :sender_id,
                :id_type

    convert :sender_id, to: :text
    convert :id_type,   to: :text

    validates_presence_of :messages
    validates_length_of :sender_id, maximum: 22
    validates_length_of :id_type, maximum: 4, minimum: 1

    validate do |record|
      message = record.messages.first

      # Ensure that all messages are of the same type
      record.errors.add(:messages, :invalid) if record.messages.any? { |m| !m.is_a?(message.class) }
      record.errors.add(:messages, :invalid) if record.messages.any? { |m| !m.valid? }
    end

    class_attribute :known_schemas

    self.known_schemas = [CONTAINER_NNN_001_GBIC4, CONTAINER_NNN_001_04, CONTAINER_NNN_001_02]

    def initialize(container_options = {})
      @sender_id = container_options[:sender_id]
      @id_type   = container_options[:id_type]

      @messages = []
    end

    def add_message(message)
      messages << message
    end

    def to_xml(schema_name = self.known_schemas.first)
      raise SEPA::Error.new(errors.full_messages.join("\n")) unless valid?

      unless schema_compatible?(schema_name)
        raise SEPA::Error.new("Incompatible with schema #{schema_name}!")
      end

      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml_builder|
        xml_builder.conxml(xml_schema(schema_name)) do
          xml_builder.ContainerId do
            xml_builder.SenderId(sender_id)
            xml_builder.IdType(id_type)
            xml_builder.TimeStamp(Time.parse(creation_date_time).strftime('%H%M%S%L'))
          end
          xml_builder.CreDtTm(creation_date_time)
          build_messages(xml_builder, schema_name)
        end
      end

      validate_final_document!(builder.doc, schema_name)
      builder.to_xml
    end

    def schema_compatible?(schema_name)
      unless self.known_schemas.include?(schema_name)
        raise ArgumentError.new("Schema #{schema_name} is unknown!")
      end

      messages.all? do |m|
        message_schema = schema_for_message(schema_name, m)

        m.schema_compatible?(message_schema)
      end
    end

    def validate_final_document!(document, schema_name)
      schema_dir = File.expand_path('../../lib/schema', __dir__)

      xsd = nil

      Dir.chdir(schema_dir) do
        xsd = Nokogiri::XML::Schema(File.read("#{schema_name}.xsd"))
      end

      errors = xsd.validate(document).map(&:message)
      if errors.any?
        raise SEPA::Error.new("Incompatible with schema #{schema_name}: #{errors.join(', ')}")
      end
    end

    # Get creation date time for the message (with fallback to Time.now.iso8601)
    def creation_date_time
      @creation_date_time ||= Time.now.iso8601
    end

    private

      def xml_schema(schema_name)
        return {
          xmlns:                "urn:conxml:xsd:#{schema_name}",
          'xmlns:xsi':          'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:schemaLocation': "urn:conxml:xsd:#{schema_name} #{schema_name}.xsd",
        }
      end

      def schema_for_message(container_name, message)
        message_schemas = CONTAINER_TO_MESSAGE_MAPPING[container_name]

        message_schemas[message.class]
      end

      def build_messages(builder, schema_name)
        # We assume at this point that all messages are of the same class
        message_type = messages.first.is_a?(SEPA::CreditTransfer) ? 'MsgPain001' : 'MsgPain008'

        messages.each do |message|
          xml_string = message.to_xml(schema_for_message(schema_name, message))
          doc = Nokogiri::XML(xml_string)
          doc.xpath('//@xmlns:xsi').remove
          doc.xpath('//@xsi:schemaLocation').remove

          canonical_xml = doc.canonicalize

          # Generate hash from the canonical XML
          hash_value = Digest::SHA256.hexdigest(canonical_xml).upcase

          builder.__send__(message_type) do
            builder.HashValue(hash_value)
            builder.HashAlgorithm('SHA256')
            builder << canonical_xml
          end
        end
      end

  end

end
