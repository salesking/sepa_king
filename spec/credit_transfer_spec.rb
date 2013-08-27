# encoding: utf-8
require 'spec_helper'

describe SEPA::CreditTransfer do
  let(:credit_transfer) {
    SEPA::CreditTransfer.new name:       'Schuldner GmbH',
                             bic:        'BANKDEFFXXX',
                             iban:       'DE87200500001234567890'
  }

  describe :new do
    it 'should accept missing options' do
      expect {
        SEPA::CreditTransfer.new
      }.to_not raise_error
    end
  end

  describe :add_transaction do
    it 'should add valid transactions' do
      3.times {
        credit_transfer.add_transaction name:                   'Telekomiker AG',
                                        bic:                    'PBNKDEFF370',
                                        iban:                   'DE37112589611964645802',
                                        amount:                 102.50,
                                        reference:              'XYZ-1234/123',
                                        remittance_information: 'Rechnung vom 22.08.2013'
      }

      expect(credit_transfer).to have(3).transactions
    end

    it 'should fail for invalid transaction' do
      expect {
        credit_transfer.add_transaction name: ''
      }.to raise_error(ArgumentError)
    end
  end

  describe :to_xml do
    context 'for invalid debtor' do
      it 'should fail' do
        expect {
          SEPA::CreditTransfer.new.to_xml
        }.to raise_error(RuntimeError)
      end
    end

    context 'for valid debtor' do
      before :each do
        @ct = credit_transfer

        @ct.add_transaction name:                   'Telekomiker AG',
                            bic:                    'PBNKDEFF370',
                            iban:                   'DE37112589611964645802',
                            amount:                 102.50,
                            reference:              'XYZ-1234/123',
                            remittance_information: 'Rechnung vom 22.08.2013'

        @ct.add_transaction name:                   'Amazonas GmbH',
                            bic:                    'TUBDDEDDXXX',
                            iban:                   'DE27793589132923472195',
                            amount:                 59.00,
                            reference:              'XYZ-5678/456',
                            remittance_information: 'Rechnung vom 21.08.2013'
      end

      it 'should create valid XML file' do
        expect(@ct.to_xml).to validate_against('pain.001.002.03.xsd')
      end

      it 'should contain <PmtMtd>' do
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/PmtMtd', 'TRF')
      end

      it 'should contain <NbOfTxs>' do
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/NbOfTxs', '2')
      end

      it 'should contain <CtrlSum>' do
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CtrlSum', '161.50')
      end

      it 'should contain <Dbtr>' do
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/Dbtr/Nm', 'Schuldner GmbH')
      end

      it 'should contain <DbtrAcct>' do
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/DbtrAcct/Id/IBAN', 'DE87200500001234567890')
      end

      it 'should contain <DbtrAgt>' do
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/DbtrAgt/FinInstnId/BIC', 'BANKDEFFXXX')
      end

      it 'should contain <EndToEndId>' do
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[1]/PmtId/EndToEndId', 'XYZ-1234/123')
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[2]/PmtId/EndToEndId', 'XYZ-5678/456')
      end

      it 'should contain <Amt>' do
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[1]/Amt/InstdAmt', '102.50')
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[2]/Amt/InstdAmt', '59.00')
      end

      it 'should contain <CdtrAgt>' do
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[1]/CdtrAgt/FinInstnId/BIC', 'PBNKDEFF370')
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[2]/CdtrAgt/FinInstnId/BIC', 'TUBDDEDDXXX')
      end

      it 'should contain <Cdtr>' do
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[1]/Cdtr/Nm', 'Telekomiker AG')
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[2]/Cdtr/Nm', 'Amazonas GmbH')
      end

      it 'should contain <CdtrAcct>' do
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[1]/CdtrAcct/Id/IBAN', 'DE37112589611964645802')
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[2]/CdtrAcct/Id/IBAN', 'DE27793589132923472195')
      end

      it 'should contain <RmtInf>' do
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[1]/RmtInf/Ustrd', 'Rechnung vom 22.08.2013')
        @ct.to_xml.should have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[2]/RmtInf/Ustrd', 'Rechnung vom 21.08.2013')
      end
    end
  end
end
