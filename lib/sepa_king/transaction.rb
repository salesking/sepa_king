# encoding: utf-8
module SEPA
  class Transaction
    include ActiveModel::Validations
    extend Converter

    attr_accessor :name, :iban, :bic, :amount, :reference, :remittance_information, :requested_date
    convert :name, :reference, :remittance_information, to: :text
    convert :amount, to: :decimal

    validates_length_of :name, within: 1..70
    validates_length_of :reference, within: 1..35, allow_nil: true
    validates_length_of :remittance_information, within: 1..140, allow_nil: true
    validates_numericality_of :amount, greater_than: 0
    validates_with BICValidator, IBANValidator

    validate do |t|
      if t.requested_date.is_a?(Date)
        errors.add(:requested_date, 'is not in the future') if t.requested_date <= Date.today
      end
    end

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end
  end
end
