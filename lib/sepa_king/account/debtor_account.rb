# encoding: utf-8
module SEPA
  class DebtorAccount < Account
    attr_accessor :debtor_identifier

    def identifier
      debtor_identifier
    end

    validates_with DebtorIdentifierValidator, message: "%{value} is invalid"
  end
end
