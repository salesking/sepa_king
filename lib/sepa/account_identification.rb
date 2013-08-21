# encoding: utf-8
require 'sepa/base'

# Identifikation des Kontos
class SEPA::AccountIdentification < SEPA::Base
  # International Bank Account Number (IBAN)
  attribute :iban, 'IBAN'
end
