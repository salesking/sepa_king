# encoding: utf-8
require 'spec_helper'

describe SEPA::IBANValidator do
  class Validatable
    include ActiveModel::Model
    attr_accessor :iban, :iban_the_terrible
    validates_with SEPA::IBANValidator
    validates_with SEPA::IBANValidator, field_name: :iban_the_terrible
  end

  it 'should accept valid IBAN' do
    Validatable.should accept('DE21500500009876543210', 'DE87200500001234567890', for: [:iban, :iban_the_terrible])
  end

  it 'should not accept an invalid IBAN' do
    Validatable.should_not accept('', 'xxx', 'DE22500500009876543210', 'DE2150050000987654321', for: [:iban, :iban_the_terrible])
  end
end

describe SEPA::BICValidator do
  class Validatable
    include ActiveModel::Model
    attr_accessor :bic, :custom_bic
    validates_with SEPA::BICValidator
    validates_with SEPA::BICValidator, field_name: :custom_bic
  end

  it 'should accept valid BICs' do
    Validatable.should accept('DEUTDEDBDUE', 'DUSSDEDDXXX', for: [:bic, :custom_bic])
  end

  it 'should not accept an invalid BIC' do
    Validatable.should_not accept('', 'GENODE61HR', 'DEUTDEDBDUEDEUTDEDBDUE', for: [:bic, :custom_bic])
  end
end

describe SEPA::CreditorIdentifierValidator do
  class Validatable
    include ActiveModel::Model
    attr_accessor :creditor_identifier, :crid
    validates_with SEPA::CreditorIdentifierValidator
    validates_with SEPA::CreditorIdentifierValidator, field_name: :crid
  end

  it 'should accept valid creditor_identifier' do
    Validatable.should accept('DE98ZZZ09999999999', 'AT12ZZZ00000000001', 'FR12ZZZ123456', 'NL97ZZZ123456780001', for: [:creditor_identifier, :crid])
  end

  it 'should not accept an invalid creditor_identifier' do
    Validatable.should_not accept('', 'xxx', 'DE98ZZZ099999999990', for: [:creditor_identifier, :crid])
  end
end

describe SEPA::MandateIdentifierValidator do
  class Validatable
    include ActiveModel::Model
    attr_accessor :mandate_id, :mid
    validates_with SEPA::MandateIdentifierValidator
    validates_with SEPA::MandateIdentifierValidator, field_name: :mid
  end

  it 'should accept valid mandate_identifier' do
    Validatable.should accept('XY Z-123', "+?/-:().,'", 'X' * 35, for: [:mandate_id, :mid])
  end

  it 'should not accept an invalid mandate_identifier' do
    Validatable.should_not accept(nil, '', 'X' * 36, '#/*', 'Ümläüt', for: [:mandate_id, :mid])
  end
end
