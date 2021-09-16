# encoding: utf-8
module SEPA
  class CreditorAccount < Account
    attr_accessor :creditor_identifier

    def identifier
      creditor_identifier
    end

    validates_with CreditorIdentifierValidator, message: "%{value} is invalid"
  end
end
