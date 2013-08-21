# encoding: utf-8
require 'sepa/base'
require 'sepa/cash_account'
require 'sepa/party_identification'
require 'sepa/payment_identification'
require 'sepa/payment_type_information'
require 'sepa/direct_debit_transaction'
require 'sepa/branch_and_financial_institution_identification'

# Einzeltransaktion
class SEPA::DirectDebitTransactionInformation < SEPA::Base
  # Referenzierung einer einzelnen Transaktion
  attribute :payment_identification        , 'PmtId'          , SEPA::PaymentIdentification

  # beauftragter Betrag
  attribute :instructed_amount             , 'InstdAmt'       , :string, nil, :attributes => { :Ccy => :instructed_amount_currency }

  # Entgeltverrechnung; Über Codes identifizierbare festlegte Regeln zur Entgeltverrechnung, die Anwendung finden sollen.
  attribute :charge_bearer                 , 'ChrgBr'

  # Angaben zum Lastschriftmandat
  attribute :direct_debit_transaction      , 'DrctDbtTx'      , SEPA::DirectDebitTransaction

  # Abweichender Zahlungsempfänger. Hat rein informatorischen Charakter.
  attribute :ultimate_creditor             , 'UltmtCdtr'      , SEPA::PartyIdentification

  # Kreditinstitut des Zahlers (Zahlungspflichtigen)
  attribute :debtor_agent                  , 'DbtrAgt'        , SEPA::BranchAndFinancialInstitutionIdentification

  # Pflichtfeld für Angaben zum Zahler (Zahlungspflichtigen)
  attribute :debtor                        , 'Dbtr'           , SEPA::PartyIdentification

  # Konto des Zahlers (Zahlungspflichtigen)
  attribute :debtor_account                , 'DbtrAcct'       , SEPA::CashAccount

  # Zahler (Zahlungspflichtiger) sofern abweichend vom Kontoinhaber, z. B. Kind des Kontoinhabers. Hat rein informatorischen Charakter.
  attribute :ultimate_debtor               , 'UltmtDbtr'      , SEPA::PartyIdentification

  # Art der Zahlung
  attribute :purpose                       , 'Purp'           #, SEPA::Purpose

  # Verwendungszweckinformationen
  attribute :remittance_information        , 'RmtInf'         #, SEPA::RemittanceInformation
end
