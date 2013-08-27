# encoding: utf-8
module SEPA
  class Transaction
    include ActiveModel::Validations
    extend Converter

    attr_accessor :name, :iban, :bic, :amount, :reference, :remittance_information
    convert :name, :reference, :remittance_information, to: :text
    convert :amount, to: :decimal

    validates_length_of :name, within: 1..70
    validates_length_of :bic, within: 8..11
    validates_length_of :reference, within: 1..35, allow_nil: true
    validates_length_of :remittance_information, within: 1..140, allow_nil: true
    validates_numericality_of :amount, greater_than: 0

    validate do |t|
      errors.add(:iban, 'is invalid') unless IBANTools::IBAN.valid?(t.iban.to_s)
    end

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end
  end
end
