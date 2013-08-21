# encoding: utf-8
require 'sepa/base'

# Referenzierung einer einzelnen Transaktion
class SEPA::PaymentIdentification < SEPA::Base
  # eindeutige Referenz des Lastschrifteinreichers an sein Kreditinstitut (Punkt-zu-Punkt-Referenz)
  attribute :instruction_identification, 'InstrId'

  # eindeutige Referenz des Lastschrifteinreichers
  # Diese Referenz wird unverändert durch die gesamte Kette bis zum Zahler (Zahlungspflichtigen) geleitet (Ende-zu-Ende-Referenz)
  attribute :end_to_end_identification, 'EndToEndId'
end
