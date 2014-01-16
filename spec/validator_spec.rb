# encoding: utf-8
require 'spec_helper'

describe SEPA::BICValidator do
  class Validatable
    include ActiveModel::Model
    attr_accessor :bic
    validates_with SEPA::BICValidator
  end

  it 'should accept valid BICs' do
    Validatable.should accept('DEUTDEDBDUE', 'DUSSDEDDXXX', for: :bic)
  end

  it 'should not accept an invalid BIC' do
    Validatable.should_not accept('', 'GENODE61HR', 'DEUTDEDBDUEDEUTDEDBDUE', for: :bic)
  end
end
