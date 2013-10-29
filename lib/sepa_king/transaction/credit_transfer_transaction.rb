# encoding: utf-8
module SEPA
  class CreditTransferTransaction < Transaction
    attr_accessor :service_level

    validates_inclusion_of :service_level, :in => %w(SEPA URGP)

    def initialize(attributes = {})
      super
      self.service_level ||= 'SEPA'
    end
  end
end
