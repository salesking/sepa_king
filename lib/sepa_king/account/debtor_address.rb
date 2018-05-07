# encoding: utf-8
module SEPA
  class DebtorAddress
    include ActiveModel::Validations
    extend Converter

    attr_accessor :country_code, :address_line1, :address_line2

    convert :country_code, to: :text
    convert :address_line1, to: :text
    convert :address_line2, to: :text

    validates_length_of :country_code, is: 2
    validates_length_of :address_line1, maximum: 70
    validates_length_of :address_line2, maximum: 70

    def initialize(attributes = {})
      attributes.each do |name, value|
        public_send("#{name}=", value)
      end
    end
  end
end
