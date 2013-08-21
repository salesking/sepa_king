# encoding: utf-8
require 'sepa/base'
require 'sepa/account_identification'

class SEPA::CashAccount < SEPA::Base
  # Identifikation des Kontos
  attribute :identification, 'Id', SEPA::AccountIdentification
end
