# encoding: utf-8
module SEPA
  class Transaction
    include ActiveModel::Validations
    extend Converter

    DEFAULT_REQUESTED_DATE = Date.new(1999, 1, 1).freeze

    attr_accessor :name, :iban, :bic, :amount, :instruction, :reference, :remittance_information, :requested_date, :batch_booking, :currency, :debtor_address

    convert :name, :instruction, :reference, :remittance_information, to: :text
    convert :amount, to: :decimal

    validates_length_of :name, within: 1..70
    validates_length_of :currency, is: 3
    validates_length_of :instruction, within: 1..35, allow_nil: true
    validates_length_of :reference, within: 1..35, allow_nil: true
    validates_length_of :remittance_information, within: 1..140, allow_nil: true
    validates_numericality_of :amount, greater_than: 0
    validates_presence_of :requested_date
    validates_inclusion_of :batch_booking, :in => [true, false]
    validates_with BICValidator, IBANValidator, message: "%{value} is invalid"

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end

      self.requested_date ||= DEFAULT_REQUESTED_DATE
      self.reference ||= 'NOTPROVIDED'
      self.batch_booking = true if self.batch_booking.nil?
      self.currency ||= 'EUR'
    end

    protected

    def validate_requested_date_after(min_requested_date)
      return unless requested_date.is_a?(Date)

      if requested_date != DEFAULT_REQUESTED_DATE && requested_date < min_requested_date
        errors.add(:requested_date, "must be greater or equal to #{min_requested_date}, or nil")
      end
    end
  end
end
