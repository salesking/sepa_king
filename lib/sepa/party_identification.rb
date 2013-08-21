# encoding: utf-8
require 'sepa/base'
require 'sepa/identification'

class SEPA::PartyIdentification < SEPA::Base
  # Name
  attribute :name                , 'Nm'

  # eindeutiges Identifizierungsmerkmal einer Organisation oder Person
  attribute :identification      , 'Id'       , SEPA::Identification
end
