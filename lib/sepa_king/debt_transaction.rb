# encoding: utf-8
module SEPA
  class DebtTransaction
    include TextConverter
    attr_reader :name, :iban, :bic, :amount, :reference, :mandate_id, :mandate_date_of_signature

    def initialize(options)
      options.each_pair do |k,v|
        send("#{k}=", v)
      end
    end

    def name=(value)
      raise ArgumentError.new('Name is missing') unless value
      @name = convert_text(value)
    end

    def iban=(value)
      raise ArgumentError.new('IBAN is missing') unless value
      raise ArgumentError.new("IBAN has wrong length: #{value.length}, must be between 15-34") unless value.length.between?(15,34)
      @iban = value
    end

    def bic=(value)
      raise ArgumentError.new('BIC is missing') unless value
      raise ArgumentError.new("BIC has wrong length: #{value.length} must be between 8-11") unless value.length.between?(8,11)
      @bic = value
    end

    def amount=(value)
      raise ArgumentError.new('Amount is not a Number') unless value.is_a?(Numeric)
      raise ArgumentError.new('Amount cannot be zero') if value.zero?
      raise ArgumentError.new('Amount cannot be negative') if value < 0
      @amount = value
    end

    def reference=(value)
      raise ArgumentError.new('Reference is missing') unless value
      raise ArgumentError.new("Reference has wrong length: #{value.length}, must be 35 maximum") if value.length > 35
      @reference = convert_text(value)
    end

    def mandate_id=(value)
      raise ArgumentError.new('Mandate ID is missing') unless value
      @mandate_id = convert_text(value)
    end

    def mandate_date_of_signature=(value)
      raise ArgumentError.new('Mandate Date of Signature is missing') unless value.is_a?(Date)
      @mandate_date_of_signature = value
    end
  end
end
