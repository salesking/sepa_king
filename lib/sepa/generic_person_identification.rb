# encoding: utf-8
require 'sepa/base'
require 'sepa/person_identification_schema_name'

class SEPA::GenericPersonIdentification < SEPA::Base
  # eindeutiges Identifizierungsmerkmal einer Person
  attribute :identification,                         'Id'

  # Name des Schemas
  attribute :scheme_name,                            'SchmeNm', SEPA::PersonIdentificationSchemaName

  # Aussteller der Identifikation
  attribute :initiating_party_identification_issuer, 'Issr'
end
