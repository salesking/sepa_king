# encoding: utf-8
module SEPA
  class Account
    include ActiveModel::Validations
    extend Converter

    attr_accessor :name, :iban, :bic
    convert :name, :to => :text

    validates_presence_of :name, :iban, :bic
    validates_length_of :name, :maximum => 70
    validates_length_of :bic, :within => 8..11

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
