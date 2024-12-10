# encoding: utf-8
module SEPA
  class CreditTransferTransaction < Transaction
    LOCAL_INSTRUMENTS = %w(INST)

    attr_accessor :service_level,
                  :creditor_address,
                  :category_purpose,
                  :local_instrument

    validates_inclusion_of :service_level, :in => %w(SEPA URGP), :allow_nil => true
    validates_length_of :category_purpose, within: 1..4, allow_nil: true
    validates_inclusion_of :local_instrument, in: LOCAL_INSTRUMENTS, :allow_nil => true

    validate :inst_valid_for_sepa_service_level

    validate { |t| t.validate_requested_date_after(Date.today) }

    def initialize(attributes = {})
      super
      self.service_level ||= 'SEPA' if self.currency == 'EUR'
    end

    def schema_compatible?(schema_name)
      case schema_name
      when PAIN_001_001_03
        !self.service_level || (self.service_level == 'SEPA' && self.currency == 'EUR')
      when PAIN_001_002_03
        self.bic.present? && self.service_level == 'SEPA' && self.currency == 'EUR' && self.local_instrument.nil?
      when PAIN_001_003_03
        self.currency == 'EUR' && self.local_instrument.nil?
      when PAIN_001_001_03_CH_02
        self.currency == 'CHF' && self.local_instrument.nil?
      end
    end

    private

    def inst_valid_for_sepa_service_level
      if self.local_instrument == 'INST' && self.service_level != 'SEPA'
        errors.add(:local_instrument, 'INST can only be used with SEPA service level')
      end
    end
  end
end
