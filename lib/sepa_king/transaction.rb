# encoding: utf-8
module SEPA
  class Transaction
    include ActiveModel::Validations
    extend Converter

    attr_accessor :name, :iban, :bic, :amount, :instruction, :reference, :remittance_information, :requested_date, :batch_booking
    convert :name, :instruction, :reference, :remittance_information, to: :text
    convert :amount, to: :decimal

    validates_length_of :name, within: 1..70
    validates_length_of :instruction, within: 1..35, allow_nil: true
    validates_length_of :reference, within: 1..35, allow_nil: true
    validates_length_of :remittance_information, within: 1..140, allow_nil: true
    validates_numericality_of :amount, greater_than: 0
    validates_presence_of :requested_date
    validates_inclusion_of :batch_booking, :in => [true, false]
    validates_with BICValidator, IBANValidator

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end

      self.requested_date ||= Date.today.next
      self.reference ||= 'NOTPROVIDED'
      self.batch_booking = true if self.batch_booking.nil?
    end
  end
end
