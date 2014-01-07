# encoding: utf-8
module SEPA
  class DirectDebitTransaction < Transaction
    attr_accessor :mandate_id, :mandate_date_of_signature, :local_instrument, :sequence_type, :creditor_account

    validates_format_of :mandate_id, :with => /\A([A-Za-z0-9]|[\+|\?|\/|\-|\:|\(|\)|\.|\,|\']){1,35}\z/
    validates_presence_of :mandate_date_of_signature
    validates_inclusion_of :local_instrument, :in => %w(CORE COR1 B2B)
    validates_inclusion_of :sequence_type, :in => %w(FRST OOFF RCUR FNAL)

    validate do |t|
      if creditor_account
        errors.add(:creditor_account, 'is not correct') unless creditor_account.valid?
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

    def schema_compatible?(schema_name)
      case schema_name
      when PAIN_008_001_02, PAIN_008_002_02
        self.bic.present? && %w(CORE B2B).include?(self.local_instrument)
      when PAIN_008_003_02
        true
      end
    end
  end
end
