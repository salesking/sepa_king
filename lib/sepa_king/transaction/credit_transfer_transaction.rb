# encoding: utf-8
module SEPA
  class CreditTransferTransaction < Transaction
    attr_accessor :service_level

    validates_inclusion_of :service_level, :in => %w(SEPA URGP)

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
