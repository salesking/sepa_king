# encoding: utf-8
module SEPA
  class DebtTransaction < Transaction
    attr_reader :mandate_id, :mandate_date_of_signature

    def mandate_id=(value)
      raise ArgumentError.new('Mandate ID is missing') if value.nil? || value.empty?
      raise ArgumentError.new("Mandate ID is too long: #{value.length}, must be 35 maximum") if value.length > 35
      @mandate_id = convert_text(value)
    end

    def mandate_date_of_signature=(value)
      raise ArgumentError.new('Mandate Date of Signature is missing') unless value.is_a?(Date)
      raise ArgumentError.new('Mandate Date of Signature is in the future') if value > Date.today
      @mandate_date_of_signature = value
    end
  end
end
