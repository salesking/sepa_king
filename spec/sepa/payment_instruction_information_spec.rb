require 'spec_helper'

describe SEPA::PaymentInstructionInformation do
  it 'should calc control_sum' do
    p = SEPA::PaymentInstructionInformation.new(
      :direct_debit_transaction_information => [
        SEPA::DirectDebitTransactionInformation.new(
          :instructed_amount => '123.45'
        ),
        SEPA::DirectDebitTransactionInformation.new(
          :instructed_amount => '567.90'
        )
      ]
    )

    p.control_sum.should == '691.35'
  end
end
