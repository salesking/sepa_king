# encoding: utf-8
module SEPA
  class Account
    include ActiveModel::Model
    include TextConverter

    attr_accessor :name, :iban, :bic

    validates_presence_of :name, :iban, :bic
    validates_length_of :name, :maximum => 70
    validates_length_of :bic, :within => 8..11

    validate do |t|
      if t.iban
        errors.add(:iban, 'is invalid') unless IBANTools::IBAN.valid?(t.iban)
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
