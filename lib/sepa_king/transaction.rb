# encoding: utf-8
module SEPA
  class Transaction
    include ActiveModel::Validations
    extend Converter

    attr_accessor :name, :iban, :bic, :amount, :reference, :remittance_information
    convert :name, :reference, :remittance_information, to: :text
    convert :amount, to: :decimal

    validates_presence_of :name, :iban, :bic, :amount
    validates_length_of :name, maximum: 70
    validates_length_of :bic, within: 8..11
    validates_length_of :reference, maximum: 35, minimum: 1, allow_nil: true
    validates_length_of :remittance_information, minimum: 1, maximum: 140, allow_nil: true
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
