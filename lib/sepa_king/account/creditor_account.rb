# encoding: utf-8
module SEPA
  class CreditorAccount < Account
    attr_accessor :creditor_identifier,
                  :isr_participant_number

    validates_with CreditorIdentifierValidator,
                   message: "%{value} is invalid"
    validates_format_of :isr_participant_number, with: /\A\d{9}\z/, allow_nil: true
  end
end
