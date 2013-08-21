# encoding: utf-8
require 'sepa/base'
require 'sepa/mandate_related_information'

# Angaben zum Lastschriftmandat
class SEPA::DirectDebitTransaction < SEPA::Base
  # mandatsbezogene Informationen
  attribute :mandate_related_information, 'MndtRltdInf', SEPA::MandateRelatedInformation

  # Identifikation des Zahlungsempfängers
  attribute :creditor_scheme_identification, 'CdtrSchmeId', SEPA::PartyIdentification
end

