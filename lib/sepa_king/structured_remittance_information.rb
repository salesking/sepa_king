module SEPA
  class StructuredRemittanceInformation
    include ActiveModel::Validations
    extend Converter

    attr_accessor :proprietary,
                  :reference

    validates_inclusion_of :proprietary, in: %w(ESR IPI)
    validates_length_of :reference, within: 1..35

    convert :proprietary, :reference, to: :text

    def initialize(attributes = {})
      attributes.each do |name, value|
        public_send("#{name}=", value)
      end
    end
  end
end
