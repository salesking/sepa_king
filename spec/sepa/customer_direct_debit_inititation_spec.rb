require 'spec_helper'

describe SEPA::CustomerDirectDebitInitiation do
  it 'should create valid XML file' do
    ddi = SEPA::CustomerDirectDebitInitiation.new(
      :group_header => SEPA::GroupHeader.new(
        :message_identification => 'Message-ID',
        :creation_date_time     => Time.now,
        :number_of_transactions => 1,
        :initiating_party       => SEPA::PartyIdentification.new(
          :name => 'Initiator Name'
        )
      ),

      :payment_instruction_information => [
        SEPA::PaymentInstructionInformation.new(
          :payment_information_identification => 'Payment-ID',
          :payment_method                     => 'DD',
          :requested_collection_date          => Date.today,
          :payment_type_information           => SEPA::PaymentTypeInformation.new(
            :sequence_type => 'FRST',
            :service_level => SEPA::ServiceLevel.new(
              :code => 'SEPA'
            ),
            :local_instrument => SEPA::LocalInstrument.new(
              :code => 'CORE'
            )
          ),
          :creditor => SEPA::PartyIdentification.new(
            :name => 'Creditor Name'
          ),
          :creditor_account => SEPA::CashAccount.new(
            :identification => SEPA::AccountIdentification.new(
              :iban => 'DE87200500001234567890'
            )
          ),
          :creditor_agent => SEPA::BranchAndFinancialInstitutionIdentification.new(
            :financial_institution_identification => SEPA::FinancialInstitutionIdentification.new(
              :bic => 'BANKDEFFXXX'
            )
          ),
          :charge_bearer                      => 'SLEV',
          :creditor_scheme_identification     => SEPA::PartyIdentification.new(
            :identification => SEPA::Identification.new(
              :private_identification => SEPA::PersonIdentification.new(
                :other => SEPA::GenericPersonIdentification.new(
                  :identification => 'DE00ZZZ00099999999',
                  :scheme_name => SEPA::PersonIdentificationSchemaName.new(
                    :proprietary => 'SEPA'
                  )
                )
              )
            )
          ),
          :direct_debit_transaction_information => [
            SEPA::DirectDebitTransactionInformation.new(
              :payment_identification => SEPA::PaymentIdentification.new(
                :end_to_end_identification => 'OriginatorID1235'
              ),
              :instructed_amount => '6543.14',
              :instructed_amount_currency => 'EUR',
              :debtor => SEPA::PartyIdentification.new(
                :name => 'Debtor Name'
              ),
              :debtor_account => SEPA::CashAccount.new(
                :identification => SEPA::AccountIdentification.new(
                  :iban => 'DE21500500009876543210'
                )
              ),
              :debtor_agent => SEPA::BranchAndFinancialInstitutionIdentification.new(
                :financial_institution_identification => SEPA::FinancialInstitutionIdentification.new(
                  :bic => 'SPUEDE2UXXX'
                )
              ),
              :direct_debit_transaction => SEPA::DirectDebitTransaction.new(
                :mandate_related_information => SEPA::MandateRelatedInformation.new(
                  :mandate_identification => 'Mandate-Id',
                  :date_of_signature => Date.new(2010,11,20)
                )
              )
            )
          ],
          :control_sum => '123.00'
        )
      ]
    )

    XML::Document.string(ddi.generate_xml).should validate_against('pain.008.002.02.xsd')
  end
end
