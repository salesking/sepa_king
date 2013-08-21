# encoding: utf-8
require 'sepa/base'
require 'sepa/party_identification'

# Kenndaten, die für alle Transaktionen innerhalb der SEPA-Nachricht gelten
class SEPA::GroupHeader < SEPA::Base
  # Punkt-zu-Punkt- Referenz der anweisenden Partei für die folgende Partei in der Nachrichten-Kette, um die Nachricht (Datei) eindeutig zu identifizieren
  attribute :message_identification, 'MsgId'

  # Datum und Zeit, wann die ZV-Nachricht durch die anweisende Partei erzeugt wurde
  attribute :creation_date_time    , 'CreDtTm', Time

  # Anzahl der einzelnen Transaktionen innerhalb der gesamten Nachricht
  attribute :number_of_transactions, 'NbOfTxs'

  # Summe der Beträge aller Einzeltransaktionen in der gesamten Nachricht
  attribute :control_sum           , 'CtrlSum' do |instance|
    # TODO
  end

  # Partei, welche die Zahlung anweist, d. h. der Zahlungsempfänger oder eine Partei, welche im Auftrag des Zahlungsempfängers handelt
  attribute :initiating_party      , 'InitgPty', SEPA::PartyIdentification
end
