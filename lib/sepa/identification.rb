# encoding: utf-8
require 'sepa/base'
require 'sepa/person_identification'
require 'sepa/organisation_identification'

# eindeutiges Identifizierungsmerkmal einer Organisation oder Person
class SEPA::Identification < SEPA::Base
  # eindeutiger Identifikationscode einer Organisation
  attribute :organisation_identification, 'OrgId', SEPA::OrganisationIdentification

  # Einheitliche und eindeutige Kennung für eine natürliche Person
  attribute :private_identification, 'PrvtId', SEPA::PersonIdentification
end
