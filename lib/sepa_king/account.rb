# encoding: utf-8
module SEPA
  class Account
    include ActiveModel::Validations
    extend Converter

    attr_accessor :name, :iban, :bic, :external_organisation_id_code
    convert :name, to: :text

    validates_length_of :name, within: 1..70
    validates :external_organisation_id_code,
              format: { with: /[a-zA-Z]/ },
              length: { within: 1..4 },
              if: -> { external_organisation_id_code.present? }
    validates_with BICValidator, IBANValidator, message: "%{value} is invalid"

    def initialize(attributes = {})
      attributes.each do |name, value|
        public_send("#{name}=", value)
      end
    end
  end
end
