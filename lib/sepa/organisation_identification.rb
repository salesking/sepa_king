# encoding: utf-8
require 'sepa/base'
require 'sepa/generic_organisation_identification'

class SEPA::OrganisationIdentification < SEPA::Base
  # Business Identifier Code (SWIFT-Code) bzw. Kennung von Wirtschaftseinheiten (BEI)
  attribute :bic_or_bei, 'BICOrBEI'

  # Einheitliche und eindeutige Kennung, die einer Einrichtung zugeordnet ist
  attribute :other,      'Othr', SEPA::GenericOrganisationIdentification
end

