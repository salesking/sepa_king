# encoding: utf-8
class SEPA::CreditTransaction
  attr_reader :name, :iban, :bic, :amount, :remittance_information

  def initialize(options)
    options.each_pair do |k,v|
      send("#{k}=", v)
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

  def amount=(value)
    raise ArgumentError.new('Amount is not a number') unless value.is_a?(Numeric)
    raise ArgumentError.new('Amount cannot be zero') if value.zero?
    raise ArgumentError.new('Amount cannot be negative') if value < 0
    @amount = value
  end

  def remittance_information=(value)
    raise ArgumentError.new('Remittance information is missing') unless value
    @remittance_information = value
  end
end
