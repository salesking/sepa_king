# encoding: utf-8
require 'spec_helper'

describe SEPA::CreditTransfer do
  let(:message_id_regex) { /SEPA-KING\/[0-9a-z_]{22}/ }
  let(:credit_transfer) {
    SEPA::CreditTransfer.new name:                          'Schuldner GmbH',
                             bic:                           'BANKDEFFXXX',
                             iban:                          'DE87200500001234567890',
                             creditor_identifier:           'DE98ZZZ09999999999',
                             external_organisation_id_code: 'BANK'
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
      3.times do
        credit_transfer.add_transaction(credit_transfer_transaction)
      end

      expect(credit_transfer.transactions.size).to eq(3)
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
      context 'without BIC (IBAN-only)' do
        subject do
          sct = SEPA::CreditTransfer.new name:       'Schuldner GmbH',
                                         iban:       'DE87200500001234567890'

          sct.add_transaction name:                   'Telekomiker AG',
                              bic:                    'PBNKDEFF370',
                              iban:                   'DE37112589611964645802',
                              amount:                 102.50,
                              reference:              'XYZ-1234/123',
                              remittance_information: 'Rechnung vom 22.08.2013'

          sct
        end

        it 'should create valid XML file' do
          expect(subject.to_xml).to validate_against('pain.001.003.03.xsd')
        end

        it 'should fail for pain.001.001.03' do
          expect {
            subject.to_xml(SEPA::PAIN_001_001_03)
          }.to raise_error(RuntimeError)
        end

        it 'should fail for pain.001.002.03' do
          expect {
            subject.to_xml(SEPA::PAIN_001_002_03)
          }.to raise_error(RuntimeError)
        end
      end

      context 'with BIC' do
        subject do
          sct = credit_transfer

          sct.add_transaction name:                   'Telekomiker AG',
                              bic:                    'PBNKDEFF370',
                              iban:                   'DE37112589611964645802',
                              amount:                 102.50,
                              reference:              'XYZ-1234/123',
                              remittance_information: 'Rechnung vom 22.08.2013'

          sct
        end

        it 'should validate against pain.001.001.03' do
          expect(subject.to_xml('pain.001.001.03')).to validate_against('pain.001.001.03.xsd')
        end

        it 'should validate against pain.001.002.03' do
          expect(subject.to_xml('pain.001.002.03')).to validate_against('pain.001.002.03.xsd')
        end

        it 'should validate against pain.001.003.03' do
          expect(subject.to_xml('pain.001.003.03')).to validate_against('pain.001.003.03.xsd')
        end
      end

      context 'without requested_date given' do
        subject do
          sct = credit_transfer

          sct.add_transaction name:                   'Telekomiker AG',
                              bic:                    'PBNKDEFF370',
                              iban:                   'DE37112589611964645802',
                              amount:                 102.50,
                              reference:              'XYZ-1234/123',
                              remittance_information: 'Rechnung vom 22.08.2013'

          sct.add_transaction name:                   'Amazonas GmbH',
                              iban:                   'DE27793589132923472195',
                              amount:                 59.00,
                              reference:              'XYZ-5678/456',
                              remittance_information: 'Rechnung vom 21.08.2013'

          sct.to_xml
        end

        it 'should create valid XML file' do
          expect(subject).to validate_against('pain.001.003.03.xsd')
        end

        it 'should have message_identification' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/GrpHdr/MsgId', message_id_regex)
        end

        it 'should have creditor identifier' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/GrpHdr/InitgPty/Id/OrgId/Othr/Id', credit_transfer.account.creditor_identifier)
        end

        it 'should have external organisation indentification code' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/GrpHdr/InitgPty/Id/OrgId/Othr/SchmeNm/Cd', credit_transfer.account.external_organisation_id_code)
        end

        it 'should contain <PmtInfId>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/PmtInfId', /#{message_id_regex}\/1/)
        end

        it 'should contain <ReqdExctnDt>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/ReqdExctnDt', Date.new(1999, 1, 1).iso8601)
        end

        it 'should contain <PmtMtd>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/PmtMtd', 'TRF')
        end

        it 'should contain <BtchBookg>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/BtchBookg', 'true')
        end

        it 'should contain <NbOfTxs>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/NbOfTxs', '2')
        end

        it 'should contain <CtrlSum>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CtrlSum', '161.50')
        end

        it 'should contain <Dbtr>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/Dbtr/Nm', 'Schuldner GmbH')
        end

        it 'should contain <DbtrAcct>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/DbtrAcct/Id/IBAN', 'DE87200500001234567890')
        end

        it 'should contain <DbtrAgt>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/DbtrAgt/FinInstnId/BIC', 'BANKDEFFXXX')
        end

        it 'should contain <EndToEndId>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[1]/PmtId/EndToEndId', 'XYZ-1234/123')
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[2]/PmtId/EndToEndId', 'XYZ-5678/456')
        end

        it 'should contain <Amt>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[1]/Amt/InstdAmt', '102.50')
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[2]/Amt/InstdAmt', '59.00')
        end

        it 'should contain <CdtrAgt> for every BIC given' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[1]/CdtrAgt/FinInstnId/BIC', 'PBNKDEFF370')
          expect(subject).not_to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[2]/CdtrAgt')
        end

        it 'should contain <Cdtr>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[1]/Cdtr/Nm', 'Telekomiker AG')
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[2]/Cdtr/Nm', 'Amazonas GmbH')
        end

        it 'should contain <CdtrAcct>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[1]/CdtrAcct/Id/IBAN', 'DE37112589611964645802')
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[2]/CdtrAcct/Id/IBAN', 'DE27793589132923472195')
        end

        it 'should contain <RmtInf>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[1]/RmtInf/Ustrd', 'Rechnung vom 22.08.2013')
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[2]/RmtInf/Ustrd', 'Rechnung vom 21.08.2013')
        end
      end

      context 'with different requested_date given' do
        subject do
          sct = credit_transfer

          sct.add_transaction(credit_transfer_transaction.merge requested_date: Date.today + 1)
          sct.add_transaction(credit_transfer_transaction.merge requested_date: Date.today + 2)
          sct.add_transaction(credit_transfer_transaction.merge requested_date: Date.today + 2)

          sct.to_xml
        end

        it 'should contain two payment_informations with <ReqdExctnDt>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[1]/ReqdExctnDt', (Date.today + 1).iso8601)
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[2]/ReqdExctnDt', (Date.today + 2).iso8601)

          expect(subject).not_to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[3]')
        end

        it 'should contain two payment_informations with different <PmtInfId>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[1]/PmtInfId', /#{message_id_regex}\/1/)
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[2]/PmtInfId', /#{message_id_regex}\/2/)
        end
      end

      context 'with different batch_booking given' do
        subject do
          sct = credit_transfer

          sct.add_transaction(credit_transfer_transaction.merge batch_booking: false)
          sct.add_transaction(credit_transfer_transaction.merge batch_booking: true)
          sct.add_transaction(credit_transfer_transaction.merge batch_booking: true)

          sct.to_xml
        end

        it 'should contain two payment_informations with <BtchBookg>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[1]/BtchBookg', 'false')
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[2]/BtchBookg', 'true')

          expect(subject).not_to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[3]')
        end
      end

      context 'with transactions containing different group criteria' do
        subject do
          sct = credit_transfer

          sct.add_transaction(credit_transfer_transaction.merge requested_date: Date.today + 1, batch_booking: false, amount: 1)
          sct.add_transaction(credit_transfer_transaction.merge requested_date: Date.today + 1, batch_booking: true,  amount: 2)
          sct.add_transaction(credit_transfer_transaction.merge requested_date: Date.today + 2, batch_booking: false, amount: 4)
          sct.add_transaction(credit_transfer_transaction.merge requested_date: Date.today + 2, batch_booking: true,  amount: 8)

          sct.to_xml
        end

        it 'should contain multiple payment_informations' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[1]/ReqdExctnDt', (Date.today + 1).iso8601)
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[1]/BtchBookg', 'false')

          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[2]/ReqdExctnDt', (Date.today + 1).iso8601)
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[2]/BtchBookg', 'true')

          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[3]/ReqdExctnDt', (Date.today + 2).iso8601)
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[3]/BtchBookg', 'false')

          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[4]/ReqdExctnDt', (Date.today + 2).iso8601)
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[4]/BtchBookg', 'true')
        end

        it 'should have multiple control sums' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[1]/CtrlSum', '1.00')
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[2]/CtrlSum', '2.00')
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[3]/CtrlSum', '4.00')
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf[4]/CtrlSum', '8.00')
        end
      end

      context 'with instruction given' do
        subject do
          sct = credit_transfer

          sct.add_transaction name:                   'Telekomiker AG',
                              iban:                   'DE37112589611964645802',
                              amount:                 102.50,
                              instruction:            '1234/ABC'

          sct.to_xml
        end

        it 'should create valid XML file' do
          expect(subject).to validate_against('pain.001.003.03.xsd')
        end

        it 'should contain <InstrId>' do
          expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[1]/PmtId/InstrId', '1234/ABC')
        end
      end

      context 'with a different currency given' do
        subject do
          sct = credit_transfer

          sct.add_transaction name:                   'Telekomiker AG',
                              iban:                   'DE37112589611964645802',
                              bic:                    'PBNKDEFF370',
                              amount:                 102.50,
                              currency:               'CHF'

          sct
        end

        it 'should validate against pain.001.001.03' do
          expect(subject.to_xml('pain.001.001.03')).to validate_against('pain.001.001.03.xsd')
        end

        it 'should have a CHF Ccy' do
          doc = Nokogiri::XML(subject.to_xml('pain.001.001.03'))
          doc.remove_namespaces!

          nodes = doc.xpath('//Document/CstmrCdtTrfInitn/PmtInf/CdtTrfTxInf[1]/Amt/InstdAmt')
          expect(nodes.length).to eql(1)
          expect(nodes.first.attribute('Ccy').value).to eql('CHF')
        end

        it 'should fail for pain.001.002.03' do
          expect {
            subject.to_xml(SEPA::PAIN_001_002_03)
          }.to raise_error(RuntimeError)
        end

        it 'should fail for pain.001.003.03' do
          expect {
            subject.to_xml(SEPA::PAIN_001_003_03)
          }.to raise_error(RuntimeError)
        end
      end

      context 'with a transaction without a bic' do
        subject do
          sct = credit_transfer

          sct.add_transaction name:                   'Telekomiker AG',
                              iban:                   'DE37112589611964645802',
                              amount:                 102.50

          sct
        end

        it 'should validate against pain.001.001.03' do
          expect(subject.to_xml('pain.001.001.03')).to validate_against('pain.001.001.03.xsd')
        end

        it 'should fail for pain.001.002.03' do
          expect {
            subject.to_xml(SEPA::PAIN_001_002_03)
          }.to raise_error(RuntimeError)
        end

        it 'should validate against pain.001.003.03' do
          expect(subject.to_xml(SEPA::PAIN_001_003_03)).to validate_against('pain.001.003.03.xsd')
        end
      end
    end

    context 'when external organisation indentification code is not present and creditor identifier is' do
      let(:credit_transfer) {
        SEPA::CreditTransfer.new name:                     'Schuldner GmbH',
                                 bic:                      'BANKDEFFXXX',
                                 iban:                     'DE87200500001234567890',
                                 creditor_identifier:      'DE98ZZZ09999999999'
      }

      subject do
        credit_transfer.add_transaction(credit_transfer_transaction)
        credit_transfer.to_xml
      end

      it 'should have creditor identifier' do
        expect(subject).to have_xml('//Document/CstmrCdtTrfInitn/GrpHdr/InitgPty/Id/OrgId/Othr/Id', credit_transfer.account.creditor_identifier)
      end

      it 'should not have external organisation indentification code' do
        expect(subject).not_to have_xml('//Document/CstmrCdtTrfInitn/GrpHdr/InitgPty/Id/OrgId/Othr/SchmeNm/Cd')
      end
    end

    context 'when external organisation indentification code is present and creditor identifier is not' do
      let(:credit_transfer) {
        SEPA::CreditTransfer.new name:                     'Schuldner GmbH',
                                 bic:                      'BANKDEFFXXX',
                                 iban:                     'DE87200500001234567890'
      }

      subject do
        credit_transfer.add_transaction(credit_transfer_transaction)
        credit_transfer.to_xml
      end

      it 'should not have creditor identifier' do
        expect(subject).not_to have_xml('//Document/CstmrCdtTrfInitn/GrpHdr/InitgPty/Id/OrgId/Othr/Id')
      end

      it 'should not have external organisation indentification code' do
        expect(subject).not_to have_xml('//Document/CstmrCdtTrfInitn/GrpHdr/InitgPty/Id/OrgId/Othr/SchmeNm/Cd')
      end
    end
  end
end
