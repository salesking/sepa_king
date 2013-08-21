# encoding: utf-8
require 'sepa/base'
require 'sepa/organisation_identification_schema_name'

class SEPA::GenericOrganisationIdentification < SEPA::Base
  # Kennung. Name oder Nummer zur Wiedererkennung einer Einheit (z. B. Kontonummer)
  attribute :identification, 'Id'

  # Name des Schemas
  attribute :scheme_name, 'SchmeNm', SEPA::OrganisationIdentificationSchemaName

  # Herausgeber der Kennung
  attribute :initiating_party_identification_issuer, 'Issr'
end
