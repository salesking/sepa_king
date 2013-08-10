# encoding: utf-8
module Sepa
  # Bank account and owner information
  class Account
    include Sepa::Helper

    attr_accessor :bank_street, :bank_city,
                  :bank_zip, :bank_name, :bank_country_code, :bank_iban,
                  :bank_bic,
                  :owner_name, :owner_number, :owner_street, :owner_city,
                  :owner_zip_code, :owner_country_code
    attr_reader :bank_account_number, :bank_number

    def initialize(args={})
      args = args.dup

      @bank_street = convert_text(args.delete(:bank_street))
      @bank_city = convert_text(args.delete(:bank_city))
      @bank_name = convert_text(args.delete(:bank_name))
      @owner_name = convert_text(args.delete(:owner_name))
      @owner_street = convert_text(args.delete(:owner_street))
      @owner_city = convert_text(args.delete(:owner_city))

      args.each do |key,value|
        self.send("#{key}=",value)
      end

      raise ArgumentError.new('Owner number too long, max 10 allowed') if @owner_number && "#{@owner_number}".length > 10
      raise ArgumentError.new('Owner street too long, max 35 allowed') if @owner_street && @owner_street.length > 35
      raise ArgumentError.new('Owner city too long, max 35 allowed') if @owner_city && @owner_city.length > 35
      raise ArgumentError.new('Owner country code too long, max 2 allowed') if @owner_country_code && @owner_country_code.length > 2


      raise ArgumentError.new("Bank iban wrong length: #{@bank_iban.length}, must be between 15-34") if @bank_iban && !@bank_iban.length.between?(15,34)
      raise ArgumentError.new("Bank bic wrong length: #{@bank_bic.length} must be between 8-11") if @bank_bic && !@bank_bic.length.between?(8,11)

      raise ArgumentError.new('Bank street too long, max 35 allowed') if @bank_street && @bank_street.length > 35
      raise ArgumentError.new('Bank city too long, max 35 allowed') if @bank_city && @bank_city.length > 35
      raise ArgumentError.new('Bank name too long, max 35 allowed') if @bank_name && @bank_name.length > 35
      raise ArgumentError.new('Bank country code too long, max 2 allowed') if @bank_country_code && @bank_country_code.length > 2

      @owner_country_code = @bank_iban[0..1 ] if @bank_iban && !@owner_country_code
    end

    # Cast given account number to integer. Strips spaces and leading zeros
    # from the bank account number.
    # DTA relies on integers for checksums and field values.
    # @param [String|Integer] number
    def bank_account_number=(number)
      nr_str = "#{number}".gsub(/\s/,'')
      raise ArgumentError.new('Bank account number too long, max 10 allowed') if nr_str.length > 10
      raise ArgumentError.new('Bank account number cannot be 0') if nr_str == '0'

      @bank_account_number = nr_str.to_i
    end

    # Cast given bank number to integer. Strips spaces and leading zeros
    # from the bank account number.
    # DTA relies on integers for checksums and field values.
    # @param [String|Integer] number
    def bank_number=(number)
      nr_str = "#{number}".gsub(/\s/,'')
      raise ArgumentError.new('Bank number too long, max 8 allowed') if nr_str.length > 8
      raise ArgumentError.new('Bank number cannot be 0') if nr_str == '0'

      @bank_number = nr_str.to_i
    end

    def bank_zip_city
      "#{@bank_zip} #{@bank_city}"
    end

    def owner_zip_city
      "#{@owner_zip_code} #{@owner_city}"
    end

  end
end
