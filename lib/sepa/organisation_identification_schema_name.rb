# encoding: utf-8
require 'sepa/base'

class SEPA::OrganisationIdentificationSchemaName < SEPA::Base
  # Name gemäß einer externen Codeliste
  attribute :code       , 'Cd'

  # Name in Freitextform
  attribute :proprietary, 'Prtry'
end
