# encoding: utf-8
module SEPA
  class Transaction
    include ActiveModel::Model
    include TextConverter

    attr_accessor :name, :iban, :bic, :amount, :reference, :remittance_information

    validates_presence_of :name, :iban, :bic, :amount
    validates_length_of :name, :maximum => 70
    validates_length_of :bic, :within => 8..11
    validates_length_of :reference, :maximum => 35, :minimum => 1, :allow_nil => true
    validates_length_of :remittance_information, :minimum => 1, :maximum => 140, :allow_nil => true
    validates_numericality_of :amount, :greater_than => 0

    validate do |t|
      if t.iban
        errors.add(:iban, 'is invalid') unless IBANTools::IBAN.valid?(t.iban)
      end

      if t.amount
        errors.add(:amount, 'has more than 2 digits') if t.amount.round(2) != t.amount
      end
    end

    def initialize(options)
      options.each do |name, value|
        value = convert_text(value) if value.is_a?(String)
        send("#{name}=", value)
      end
    end
  end
end
