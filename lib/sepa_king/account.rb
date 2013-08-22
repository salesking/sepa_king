# encoding: utf-8
module SEPA
  class Account
    include Helper

    attr_reader :name, :iban, :bic, :identifier

    def initialize(options)
      options.each_pair do |k,v|
        send("#{k}=", convert_text(v))
      end
    end

    def name=(value)
      raise ArgumentError.new('Name is missing') unless value
      @name = value
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

    def identifier=(value)
      raise ArgumentError.new('Identifier is missing') unless value
      raise ArgumentError.new("Identifier has wrong length: #{value.length} must be exactly 18") unless value.length == 18
      @identifier = value
    end
  end
end
