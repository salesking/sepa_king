# encoding: utf-8
module SEPA
  class DirectDebitTransaction < Transaction
    SEPA_SERVICE_LEVELS = %w(SEPA URGP)
    SPS_SERVICE_LEVELS  = %w(CHDD CHTA)
    SERVICE_LEVELS = SEPA_SERVICE_LEVELS + SPS_SERVICE_LEVELS

    SEQUENCE_TYPES = %w(FRST OOFF RCUR FNAL)
    SEPA_LOCAL_INSTRUMENTS = %w(CORE COR1 B2B)
    SPS_LOCAL_INSTRUMENTS_FOR_SERVICE_LEVELS = {
      'CHDD' => %w(DDCOR1 DDB2B),
      'CHTA' => %w(LSV+ BDD)
    }
    SPS_LOCAL_INSTRUMENTS = SPS_LOCAL_INSTRUMENTS_FOR_SERVICE_LEVELS.map { |_, v| v }.flatten
    LOCAL_INSTRUMENTS = SEPA_LOCAL_INSTRUMENTS + SPS_LOCAL_INSTRUMENTS

    attr_accessor :service_level,
                  :mandate_id,
                  :mandate_date_of_signature,
                  :local_instrument,
                  :sequence_type,
                  :creditor_account,
                  :original_debtor_account,
                  :same_mandate_new_debtor_agent,
                  :original_creditor_account,
                  :debtor_address

    validates_with MandateIdentifierValidator,
                   field_name: :mandate_id,
                   message: "%{value} is invalid"
    validates_inclusion_of :service_level, in: SERVICE_LEVELS, allow_nil: true
    validates_inclusion_of :local_instrument, in: LOCAL_INSTRUMENTS
    validates_inclusion_of :sequence_type, in: SEQUENCE_TYPES
    validate { |t| t.validate_requested_date_after(Date.today.next) }
    validate { |t| t.validate_mandate_date_of_signature(Date.today) }

    validate do |t|
      if creditor_account
        errors.add(:creditor_account, 'is not correct') unless creditor_account.valid?
      end
    end

    def initialize(attributes = {})
      super
      self.service_level    ||= 'SEPA' if self.currency != 'CHF'
      self.local_instrument ||= 'CORE'
      self.sequence_type    ||= 'OOFF'
    end

    def amendment_informations?
      original_debtor_account || same_mandate_new_debtor_agent || original_creditor_account
    end

    def schema_compatible?(schema_name)
      case schema_name
      when PAIN_008_002_02
        self.bic.present? &&
        %w(CORE B2B).include?(self.local_instrument) &&
        self.currency == 'EUR' &&
        mandate_present?
      when PAIN_008_003_02
        self.currency == 'EUR' &&
        mandate_present?
      when PAIN_008_001_02
        mandate_present?
      when PAIN_008_001_02_CH_03
        SPS_SERVICE_LEVELS.include?(self.service_level) &&
        SPS_LOCAL_INSTRUMENTS_FOR_SERVICE_LEVELS[self.service_level].include?(self.local_instrument) &&
        !mandate_present? &&
        self.structured_remittance_information.present?
      end
    end

    def validate_mandate_date_of_signature(date)
      return if self.mandate_date_of_signature.nil?

      if self.mandate_date_of_signature.is_a?(Date)
        errors.add(:mandate_date_of_signature, 'is in the future') if self.mandate_date_of_signature > date
      else
        errors.add(:mandate_date_of_signature, 'is not a Date')
      end
    end

    def mandate_present?
      if self.mandate_id.nil? || self.mandate_date_of_signature.nil?
        return false
      end

      return true
    end
  end
end
