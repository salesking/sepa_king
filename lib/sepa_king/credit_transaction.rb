# encoding: utf-8
module SEPA
  class CreditTransaction < Transaction
    attr_reader :remittance_information

    def remittance_information=(value)
      raise ArgumentError.new('Remittance information has to be a string') unless value.is_a?(String)
      raise ArgumentError.new("Remittance information is too long: #{value.length}, must be 140 maximum") if value.length > 140
      @remittance_information = convert_text(value)
    end
  end
end
