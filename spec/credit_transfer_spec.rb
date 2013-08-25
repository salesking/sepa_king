# encoding: utf-8
require 'spec_helper'

describe SEPA::CreditTransfer do
  let(:credit_transfer) {
    SEPA::CreditTransfer.new :name       => 'Schuldner GmbH',
                             :bic        => 'BANKDEFFXXX',
                             :iban       => 'DE87200500001234567890'
  }

  describe :new do
    it 'should accept mission options' do
      expect {
        SEPA::CreditTransfer.new
      }.to_not raise_error
    end
  end

  describe :add_transaction do
    it 'should add valid transactions' do
      3.times {
        credit_transfer.add_transaction :name                   => 'Telekomiker AG',
                                        :bic                    => 'PBNKDEFF370',
                                        :iban                   => 'DE37112589611964645802',
                                        :amount                 => 102.50,
                                        :reference              => 'XYZ-1234/123',
                                        :remittance_information => 'Rechnung vom 22.08.2013'
      }

      expect(credit_transfer).to have(3).transactions
    end

    it 'should fail for invalid transaction' do
      expect {
        credit_transfer.add_transaction :name => ''
      }.to raise_error(ArgumentError)
    end
  end

  describe :to_xml do
    it 'should fail for invalid debtor' do
      expect {
        SEPA::CreditTransfer.new.to_xml
      }.to raise_error(RuntimeError)
    end

    it 'should create valid XML file' do
      ct = credit_transfer

      ct.add_transaction :name                   => 'Telekomiker AG',
                         :bic                    => 'PBNKDEFF370',
                         :iban                   => 'DE37112589611964645802',
                         :amount                 => 102.50,
                         :reference              => 'XYZ-1234/123',
                         :remittance_information => 'Rechnung vom 22.08.2013'

      ct.add_transaction :name                   => 'Amazonas GmbH',
                         :bic                    => 'TUBDDEDDXXX',
                         :iban                   => 'DE27793589132923472195',
                         :amount                 => 59.00,
                         :reference              => 'XYZ-5678/456',
                         :remittance_information => 'Rechnung vom 21.08.2013'

      expect(
        XML::Document.string(ct.to_xml)
      ).to validate_against('pain.001.002.03.xsd')
    end
  end
end
