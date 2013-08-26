# encoding: utf-8
module SEPA
  class CreditorAccount < Account
    attr_accessor :identifier

    validates_length_of :identifier, :is => 18
  end
end
