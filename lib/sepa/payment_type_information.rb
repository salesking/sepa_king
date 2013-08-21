# encoding: utf-8
require 'sepa/base'
require 'sepa/service_level'
require 'sepa/local_instrument'

# Transaktionstyp
class SEPA::PaymentTypeInformation < SEPA::Base
  # Vereinbarung oder Regel, nach der die Transaktion verarbeitet werden sollte
  attribute :service_level       , 'SvcLvl', SEPA::ServiceLevel

  # Lastschriftart
  attribute :local_instrument    , 'LclInstrm', SEPA::LocalInstrument

  # Der SequenceType gibt an, ob es sich um eine Erst-, Folge-, Einmal- oder letztmalige Lastschrift handelt.
  attribute :sequence_type       , 'SeqTp'

  # Art der Zahlung
  attribute :category_purpose    , 'CtgyPurp' #, SEPA::CategoryPurpose
end
