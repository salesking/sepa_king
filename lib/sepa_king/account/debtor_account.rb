# encoding: utf-8
module SEPA
  class DebtorAccount < Account
    attr_accessor :creditor_identifier

    validates_with CreditorIdentifierValidator,
                   message: "%{value} is invalid",
                   if: ->(account) { account.creditor_identifier.present? }
  end
end
