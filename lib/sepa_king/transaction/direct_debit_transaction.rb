# encoding: utf-8
module SEPA
  class DirectDebitTransaction < Transaction
    attr_accessor :mandate_id, :mandate_date_of_signature, :local_instrument, :sequence_type, :creditor_account

    validates_length_of :mandate_id, within: 1..35
    validates_presence_of :mandate_date_of_signature
    validates_inclusion_of :local_instrument, :in => %w(CORE B2B)
    validates_inclusion_of :sequence_type, :in => %w(FRST OOFF RCUR FNAL)

    validate do |t|
      if account.present?
        errors.add(:creditor_account, 'is not correct') if !account.valid?
      end

      if t.mandate_date_of_signature.is_a?(Date)
        errors.add(:mandate_date_of_signature, 'is in the future') if t.mandate_date_of_signature > Date.today
      else
        errors.add(:mandate_date_of_signature, 'is not a Date')
      end
    end

    def initialize(attributes = {})
      super
      self.local_instrument ||= 'CORE'
      self.sequence_type ||= 'OOFF'
    end

    def account
      return nil if creditor_account.nil?
      @account ||= SEPA::CreditorAccount.new(
        name: creditor_account[:name],
        bic: creditor_account[:bic],
        iban: creditor_account[:iban],
        creditor_identifier: creditor_account[:creditor_identifier]
      )
    end
  end
end
