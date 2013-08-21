# encoding: utf-8
require 'sepa/base'

class SEPA::DateAndPlaceOfBirth < SEPA::Base
  # Geburtsdatum
  attribute :birth_date,        'BirthDt', Date

  # Geburtsregion
  attribute :province_of_birth, 'PrvcOfBirth'

  # Geburtsort
  attribute :city_of_birth,     'CityOfBirth'

  # Geburtsland
  attribute :country_of_birth,  'CtryOfBirth'
end
