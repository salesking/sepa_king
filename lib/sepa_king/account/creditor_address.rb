# encoding: utf-8
module SEPA
  class CreditorAddress
    include ActiveModel::Validations
    extend Converter

    attr_accessor :street_name,
                  :building_number,
                  :post_code,
                  :town_name,
                  :country_code,
                  :address_line1,
                  :address_line2

    convert :street_name,     to: :text
    convert :building_number, to: :text
    convert :post_code,       to: :text
    convert :town_name,       to: :text
    convert :country_code,    to: :text
    convert :address_line1,   to: :text
    convert :address_line2,   to: :text

    validates_length_of :street_name,     maximum: 70
    validates_length_of :building_number, maximum: 16
    validates_length_of :post_code,       maximum: 16
    validates_length_of :town_name,       maximum: 35
    validates_length_of :country_code,    is: 2
    validates_length_of :address_line1,   maximum: 70
    validates_length_of :address_line2,   maximum: 70

    def initialize(attributes = {})
      attributes.each do |name, value|
        public_send("#{name}=", value)
      end
    end
  end
end
