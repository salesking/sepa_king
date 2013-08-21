# encoding: utf-8
require 'sepa/base'
require 'sepa/amendment_information_details'

# mandatsbezogene Informationen
class SEPA::MandateRelatedInformation < SEPA::Base
  # eindeutige Mandatsreferenz
  attribute :mandate_identification,        'MndtId'

  # Datum, zu dem das Mandat unterschrieben wurde
  attribute :date_of_signature,             'DtOfSgntr', Date

  # Kennzeichnet, ob das Mandat verändert wurde
  attribute :amendment_indicator,           'AmdmntInd'

  # Details der Mandatsänderung
  attribute :amendment_information_details, 'AmdmntInfDtls', SEPA::AmendmentInformationDetails

  # Platzhalter für elektronisches Mandat (e-mandate)
  attribute :electronic_signature,          'ElctrncSgntr'
end
