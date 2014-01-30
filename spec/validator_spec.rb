# encoding: utf-8
require 'spec_helper'

describe SEPA::IBANValidator do
  class Validatable
    include ActiveModel::Model
    attr_accessor :iban
    validates_with SEPA::IBANValidator
  end

  it 'should accept valid IBAN' do
    Validatable.should accept('DE21500500009876543210', 'DE87200500001234567890', for: :iban)
  end

  it 'should not accept an invalid IBAN' do
    Validatable.should_not accept('', 'xxx', 'DE22500500009876543210', 'DE2150050000987654321', for: :iban)
  end
end

describe SEPA::BICValidator do
  class Validatable
    include ActiveModel::Model
    attr_accessor :bic, :custom_bic
    validates_with SEPA::BICValidator
    validates_format_of :custom_bic, with: SEPA::BICValidator::REGEX
  end

  it 'should accept valid BICs' do
    Validatable.should accept('DEUTDEDBDUE', 'DUSSDEDDXXX', for: :bic)
    Validatable.should accept('DEUTDEDBDUE', 'DUSSDEDDXXX', for: :custom_bic)
  end

  it 'should not accept an invalid BIC' do
    Validatable.should_not accept('', 'GENODE61HR', 'DEUTDEDBDUEDEUTDEDBDUE', for: :bic)
  end
end

describe SEPA::CreditorIdentifierValidator do
  class Validatable
    include ActiveModel::Model
    attr_accessor :creditor_identifier
    validates_with SEPA::CreditorIdentifierValidator
  end

  it 'should accept valid creditor_identifier' do
    Validatable.should accept('DE98ZZZ09999999999', 'AT12ZZZ00000000001', 'FR12ZZZ123456', 'NL97ZZZ123456780001', for: :creditor_identifier)
  end

  it 'should not accept an invalid creditor_identifier' do
    Validatable.should_not accept('', 'xxx', 'DE98ZZZ099999999990', for: :creditor_identifier)
  end
end
