# encoding: utf-8
module SEPA
  class CreditTransaction < Transaction
    attr_reader :remittance_information

    def remittance_information=(value)
      raise ArgumentError.new('Remittance information is missing') unless value
      @remittance_information = convert_text(value)
    end
  end
end
