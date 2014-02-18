# encoding: utf-8
module SEPA
  class CreditTransferTransaction < Transaction
    attr_accessor :service_level

    validates_inclusion_of :service_level, :in => %w(SEPA URGP)

    validate do |t|
      if t.requested_date.is_a?(Date)
        errors.add(:requested_date, 'is in the past') if t.requested_date < Date.today
      end
    end

    def initialize(attributes = {})
      super
      self.service_level ||= 'SEPA'
    end

    def schema_compatible?(schema_name)
      case schema_name
      when PAIN_001_001_03, PAIN_001_002_03
        self.service_level == 'SEPA'
      when PAIN_001_003_03
        true
      end
    end
  end
end
