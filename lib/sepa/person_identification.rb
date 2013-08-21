# encoding: utf-8
require 'sepa/base'
require 'sepa/date_and_place_of_birth'
require 'sepa/generic_person_identification'

class SEPA::PersonIdentification < SEPA::Base
  # Geburtsort und Datum
  attribute :date_and_place_of_birth, 'DtAndPlcOfBirth', SEPA::DateAndPlaceOfBirth

  # Personen-Identifikation, die keinem definierten Identifizierungsmittel entspricht (proprietär)
  attribute :other,                   'Othr',            SEPA::GenericPersonIdentification
end

