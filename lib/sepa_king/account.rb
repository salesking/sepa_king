# encoding: utf-8
module SEPA
  class Account
    include ActiveModel::Validations
    extend Converter

    attr_accessor :name, :iban, :bic
    convert :name, to: :text

    validates_length_of :name, within: 1..70
    validates_with BICValidator, IBANValidator, message: "%{value} is invalid"

    def initialize(attributes = {})
      attributes.each do |name, value|
        public_send("#{name}=", value)
      end
    end
  end
end
