# encoding: utf-8
require 'sepa/base'
require 'sepa/payment_type_information'
require 'sepa/direct_debit_transaction_information'

# Satz von Angaben, z. B. Einreicherkonto, Fälligkeitsdatum, welcher für alle Einzeltransaktionen gilt.
# Die Payment Instruction Information entspricht einem logischen Sammler innerhalb einer physischen Datei.
class SEPA::PaymentInstructionInformation < SEPA::Base
  # Referenz zur eindeu- tigen Identifizierung des folgenden Sammlers
  attribute :payment_information_identification  , 'PmtInfId'

  # Zahlungsinstrument, hier Lastschrift
  attribute :payment_method                      , 'PmtMtd'

  # Indikator, der aussagt, ob es sich um eine Sammelbuchung (true) oder eine Einzelbuchung handelt (false)
  attribute :batch_booking                       , 'BtchBookg'

  # Anzahl der einzelnen Transaktionen innerhalb des Payment Information Blocks
  attribute :number_of_transactions              , 'NbOfTxs'

  # Summe der Beträge aller Einzeltransaktionen innerhalb des Payment Information Blocks
  attribute :control_sum                         , 'CtrlSum'

  # Transaktionstyp
  attribute :payment_type_information            , 'PmtTpInf'    , SEPA::PaymentTypeInformation

  # Fälligkeitsdatum der Lastschrift (Datum der Belastung auf dem Konto des Bezogenen)
  attribute :requested_collection_date           , 'ReqdColltnDt', Date

  # Kreditinstitut des Zahlungsempfängers
  attribute :creditor                            , 'Cdtr'        , SEPA::PartyIdentification

  # Konto des Zahlungsempfängers
  attribute :creditor_account                    , 'CdtrAcct'    , SEPA::CashAccount

  # Kreditinstitut des Zahlungsempfängers
  attribute :creditor_agent                      , 'CdtrAgt'     , SEPA::BranchAndFinancialInstitutionIdentification

  # Abweichender Zahlungsempfänger. Hat rein informatorischen Charakter.
  attribute :ultimate_creditor                   , 'UltmtCdtr'   , SEPA::PartyIdentification

  # Entgeltverrechnung; Über Codes identifizierbare festgelegte Regeln zur Entgeltverrechnung, die Anwendung finden sollen.
  attribute :charge_bearer                       , 'ChrgBr'

  # Identifikation des Zahlungsempfängers
  attribute :creditor_scheme_identification      , 'CdtrSchmeId' , SEPA::PartyIdentification

  # Einzeltransaktion
  attribute :direct_debit_transaction_information, 'DrctDbtTxInf', :[], SEPA::DirectDebitTransactionInformation
end

