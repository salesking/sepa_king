# encoding: utf-8
require 'spec_helper'

describe SEPA::DirectDebit do
  let(:message_id_regex) { /SEPA-KING\/[0-9a-z_]{22}/ }

  let(:direct_debit) {
    SEPA::DirectDebit.new name:                'Gläubiger GmbH',
                          bic:                 'BANKDEFFXXX',
                          iban:                'DE87200500001234567890',
                          creditor_identifier: 'DE98ZZZ09999999999'
  }

  describe :new do
    it 'should accept missing options' do
      expect {
        SEPA::DirectDebit.new
      }.to_not raise_error
    end
  end

  describe :add_transaction do
    it 'should add valid transactions' do
      3.times do
        direct_debit.add_transaction(direct_debt_transaction)
      end

      expect(direct_debit.transactions.size).to eq(3)
    end

    it 'should fail for invalid transaction' do
      expect {
        direct_debit.add_transaction name: ''
      }.to raise_error(ArgumentError)
    end
  end

  describe :batch_id do
    it 'returns the id of the batch where the given transactions belongs to (1 batch)' do
      direct_debit.add_transaction(direct_debt_transaction(reference: "EXAMPLE REFERENCE"))

      expect(direct_debit.batch_id("EXAMPLE REFERENCE")).to match(/#{message_id_regex}\/1/)
    end

    it 'returns the id of the batch where the given transactions belongs to (2 batches)' do
      direct_debit.add_transaction(direct_debt_transaction(reference: "EXAMPLE REFERENCE 1"))
      direct_debit.add_transaction(direct_debt_transaction(reference: "EXAMPLE REFERENCE 2", requested_date: Date.today.next.next))
      direct_debit.add_transaction(direct_debt_transaction(reference: "EXAMPLE REFERENCE 3"))

      expect(direct_debit.batch_id("EXAMPLE REFERENCE 1")).to match(/#{message_id_regex}\/1/)
      expect(direct_debit.batch_id("EXAMPLE REFERENCE 2")).to match(/#{message_id_regex}\/2/)
      expect(direct_debit.batch_id("EXAMPLE REFERENCE 3")).to match(/#{message_id_regex}\/1/)
    end
  end

  describe :batches do
    it 'returns an array of batch ids in the sepa message' do
      direct_debit.add_transaction(direct_debt_transaction(reference: "EXAMPLE REFERENCE 1"))
      direct_debit.add_transaction(direct_debt_transaction(reference: "EXAMPLE REFERENCE 2", requested_date: Date.today.next.next))
      direct_debit.add_transaction(direct_debt_transaction(reference: "EXAMPLE REFERENCE 3"))

      expect(direct_debit.batches.size).to eq(2)
      expect(direct_debit.batches[0]).to match(/#{message_id_regex}\/[0-9]+/)
      expect(direct_debit.batches[1]).to match(/#{message_id_regex}\/[0-9]+/)
    end
  end

  describe :to_xml do
    context 'for invalid creditor' do
      it 'should fail' do
        expect {
          SEPA::DirectDebit.new.to_xml
        }.to raise_error(RuntimeError)
      end
    end

    context 'for valid creditor' do
      context 'without BIC (IBAN-only)' do
        subject do
          sdd = SEPA::DirectDebit.new name:                'Gläubiger GmbH',
                                      iban:                'DE87200500001234567890',
                                      creditor_identifier: 'DE98ZZZ09999999999'

          sdd.add_transaction name:                      'Zahlemann & Söhne GbR',
                              bic:                       'SPUEDE2UXXX',
                              iban:                      'DE21500500009876543210',
                              amount:                    39.99,
                              reference:                 'XYZ/2013-08-ABO/12345',
                              remittance_information:    'Unsere Rechnung vom 10.08.2013',
                              mandate_id:                'K-02-2011-12345',
                              mandate_date_of_signature: Date.new(2011,1,25)

          sdd
        end

        it 'should validate against pain.008.003.02' do
          expect(subject.to_xml(SEPA::PAIN_008_003_02)).to validate_against('pain.008.003.02.xsd')
        end

        it 'should fail for pain.008.002.02' do
          expect {
            subject.to_xml(SEPA::PAIN_008_002_02)
          }.to raise_error(RuntimeError)
        end

        it 'should validate against pain.008.001.02' do
          expect(subject.to_xml(SEPA::PAIN_008_001_02)).to validate_against('pain.008.001.02.xsd')
        end
      end

      context 'with BIC' do
        subject do
          sdd = direct_debit

          sdd.add_transaction name:                      'Zahlemann & Söhne GbR',
                              bic:                       'SPUEDE2UXXX',
                              iban:                      'DE21500500009876543210',
                              amount:                    39.99,
                              reference:                 'XYZ/2013-08-ABO/12345',
                              remittance_information:    'Unsere Rechnung vom 10.08.2013',
                              mandate_id:                'K-02-2011-12345',
                              mandate_date_of_signature: Date.new(2011,1,25)

          sdd
        end

        it 'should validate against pain.008.001.02' do
          expect(subject.to_xml(SEPA::PAIN_008_001_02)).to validate_against('pain.008.001.02.xsd')
        end

        it 'should validate against pain.008.002.02' do
          expect(subject.to_xml(SEPA::PAIN_008_002_02)).to validate_against('pain.008.002.02.xsd')
        end

        it 'should validate against pain.008.003.02' do
          expect(subject.to_xml(SEPA::PAIN_008_003_02)).to validate_against('pain.008.003.02.xsd')
        end
      end

      context 'without requested_date given' do
        subject do
          sdd = direct_debit

          sdd.add_transaction name:                      'Zahlemann & Söhne GbR',
                              bic:                       'SPUEDE2UXXX',
                              iban:                      'DE21500500009876543210',
                              amount:                    39.99,
                              reference:                 'XYZ/2013-08-ABO/12345',
                              remittance_information:    'Unsere Rechnung vom 10.08.2013',
                              mandate_id:                'K-02-2011-12345',
                              mandate_date_of_signature: Date.new(2011,1,25)

          sdd.add_transaction name:                      'Meier & Schulze oHG',
                              iban:                      'DE68210501700012345678',
                              amount:                    750.00,
                              reference:                 'XYZ/2013-08-ABO/6789',
                              remittance_information:    'Vielen Dank für Ihren Einkauf!',
                              mandate_id:                'K-08-2010-42123',
                              mandate_date_of_signature: Date.new(2010,7,25)

          sdd.to_xml
        end

        it 'should create valid XML file' do
          expect(subject).to validate_against('pain.008.003.02.xsd')
        end

        it 'should have message_identification' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/GrpHdr/MsgId', message_id_regex)
        end

        it 'should have creditor identifier' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/GrpHdr/InitgPty/Id/OrgId/Othr/Id', direct_debit.account.creditor_identifier)
        end

        it 'should contain <PmtInfId>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/PmtInfId', /#{message_id_regex}\/1/)
        end

        it 'should contain <ReqdColltnDt>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/ReqdColltnDt', Date.new(1999, 1, 1).iso8601)
        end

        it 'should contain <PmtMtd>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/PmtMtd', 'DD')
        end

        it 'should contain <BtchBookg>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/BtchBookg', 'true')
        end

        it 'should contain <NbOfTxs>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/NbOfTxs', '2')
        end

        it 'should contain <CtrlSum>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/CtrlSum', '789.99')
        end

        it 'should contain <Cdtr>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/Cdtr/Nm', 'Gläubiger GmbH')
        end

        it 'should contain <CdtrAcct>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/CdtrAcct/Id/IBAN', 'DE87200500001234567890')
        end

        it 'should contain <CdtrAgt>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/CdtrAgt/FinInstnId/BIC', 'BANKDEFFXXX')
        end

        it 'should contain <CdtrAgt>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/CdtrSchmeId/Id/PrvtId/Othr/Id', 'DE98ZZZ09999999999')
        end

        it 'should contain <EndToEndId>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/PmtId/EndToEndId', 'XYZ/2013-08-ABO/12345')
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/PmtId/EndToEndId', 'XYZ/2013-08-ABO/6789')
        end

        it 'should contain <InstdAmt>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/InstdAmt', '39.99')
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/InstdAmt', '750.00')
        end

        it 'should contain <MndtId>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/DrctDbtTx/MndtRltdInf/MndtId', 'K-02-2011-12345')
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/DrctDbtTx/MndtRltdInf/MndtId', 'K-08-2010-42123')
        end

        it 'should contain <DtOfSgntr>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/DrctDbtTx/MndtRltdInf/DtOfSgntr', '2011-01-25')
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/DrctDbtTx/MndtRltdInf/DtOfSgntr', '2010-07-25')
        end

        it 'should contain <DbtrAgt>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/DbtrAgt/FinInstnId/BIC', 'SPUEDE2UXXX')
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/DbtrAgt/FinInstnId/Othr/Id', 'NOTPROVIDED')
        end

        it 'should contain <Dbtr>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/Dbtr/Nm', 'Zahlemann & Söhne GbR')
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/Dbtr/Nm', 'Meier & Schulze oHG')
        end

        it 'should contain <DbtrAcct>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/DbtrAcct/Id/IBAN', 'DE21500500009876543210')
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/DbtrAcct/Id/IBAN', 'DE68210501700012345678')
        end

        it 'should contain <RmtInf>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/RmtInf/Ustrd', 'Unsere Rechnung vom 10.08.2013')
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/RmtInf/Ustrd', 'Vielen Dank für Ihren Einkauf')
        end
      end

      context 'with different requested_date given' do
        subject do
          sdd = direct_debit

          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 1)
          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 2)
          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 2)

          sdd.to_xml
        end

        it 'should contain two payment_informations with <ReqdColltnDt>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[1]/ReqdColltnDt', (Date.today + 1).iso8601)
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[2]/ReqdColltnDt', (Date.today + 2).iso8601)

          expect(subject).not_to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[3]')
        end

        it 'should contain two payment_informations with different <PmtInfId>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[1]/PmtInfId', /#{message_id_regex}\/1/)
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[2]/PmtInfId', /#{message_id_regex}\/2/)
        end
      end

      context 'with different local_instrument given' do
        subject do
          sdd = direct_debit

          sdd.add_transaction(direct_debt_transaction.merge local_instrument: 'CORE')
          sdd.add_transaction(direct_debt_transaction.merge local_instrument: 'B2B')

          sdd
        end

        it 'should have errors' do
          expect(subject.errors_on(:base).size).to eq(1)
        end

        it 'should raise error on XML generation' do
          expect {
            subject.to_xml
          }.to raise_error(RuntimeError)
        end
      end

      context 'with different sequence_type given' do
        subject do
          sdd = direct_debit

          sdd.add_transaction(direct_debt_transaction.merge sequence_type: 'OOFF')
          sdd.add_transaction(direct_debt_transaction.merge sequence_type: 'FRST')
          sdd.add_transaction(direct_debt_transaction.merge sequence_type: 'FRST')

          sdd.to_xml
        end

        it 'should contain two payment_informations with <LclInstrm>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[1]/PmtTpInf/SeqTp', 'OOFF')
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[2]/PmtTpInf/SeqTp', 'FRST')

          expect(subject).not_to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[3]')
        end
      end

      context 'with different batch_booking given' do
        subject do
          sdd = direct_debit

          sdd.add_transaction(direct_debt_transaction.merge batch_booking: false)
          sdd.add_transaction(direct_debt_transaction.merge batch_booking: true)
          sdd.add_transaction(direct_debt_transaction.merge batch_booking: true)

          sdd.to_xml
        end

        it 'should contain two payment_informations with <BtchBookg>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[1]/BtchBookg', 'false')
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[2]/BtchBookg', 'true')

          expect(subject).not_to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[3]')
        end
      end

      context 'with transactions containing different group criteria' do
        subject do
          sdd = direct_debit

          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 1, sequence_type: 'OOFF', amount: 1)
          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 1, sequence_type: 'FNAL', amount: 2)
          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 2, sequence_type: 'OOFF', amount: 4)
          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 2, sequence_type: 'FNAL', amount: 8)

          sdd.to_xml
        end

        it 'should contain multiple payment_informations' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[1]/ReqdColltnDt', (Date.today + 1).iso8601)
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[1]/PmtTpInf/SeqTp', 'OOFF')

          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[2]/ReqdColltnDt', (Date.today + 1).iso8601)
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[2]/PmtTpInf/SeqTp', 'FNAL')

          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[3]/ReqdColltnDt', (Date.today + 2).iso8601)
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[3]/PmtTpInf/SeqTp', 'OOFF')

          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[4]/ReqdColltnDt', (Date.today + 2).iso8601)
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[4]/PmtTpInf/SeqTp', 'FNAL')
        end

        it 'should have multiple control sums' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[1]/CtrlSum', '1.00')
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[2]/CtrlSum', '2.00')
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[3]/CtrlSum', '4.00')
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[4]/CtrlSum', '8.00')
        end
      end

      context 'with transactions containing different creditor_account' do
        subject do
          sdd = direct_debit

          sdd.add_transaction(direct_debt_transaction)
          sdd.add_transaction(direct_debt_transaction.merge(creditor_account: SEPA::CreditorAccount.new(
                                                                                name:                'Creditor Inc.',
                                                                                bic:                 'RABONL2U',
                                                                                iban:                'NL08RABO0135742099',
                                                                                creditor_identifier: 'NL53ZZZ091734220000'))
          )

          sdd.to_xml
        end

        it 'should contain two payment_informations with <Cdtr>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[1]/Cdtr/Nm', 'Gläubiger GmbH')
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf[2]/Cdtr/Nm', 'Creditor Inc.')
        end
      end

      context 'with mandate amendments' do
        subject do
          sdd = direct_debit

          sdd.add_transaction(direct_debt_transaction.merge(original_debtor_account: 'NL08RABO0135742099'))
          sdd.add_transaction(direct_debt_transaction.merge(same_mandate_new_debtor_agent: true))
          sdd.to_xml
        end

        it 'should include amendment indicator' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/DrctDbtTx/MndtRltdInf/AmdmntInd', 'true')
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/DrctDbtTx/MndtRltdInf/AmdmntInd', 'true')
        end

        it 'should include amendment information details' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/DrctDbtTx/MndtRltdInf/AmdmntInfDtls/OrgnlDbtrAcct/Id/IBAN', 'NL08RABO0135742099')
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/DrctDbtTx/MndtRltdInf/AmdmntInfDtls/OrgnlDbtrAgt/FinInstnId/Othr/Id', 'SMNDA')
        end
      end

      context 'with instruction given' do
        subject do
          sct = direct_debit

          sct.add_transaction(direct_debt_transaction.merge(instruction: '1234/ABC'))

          sct.to_xml
        end

        it 'should create valid XML file' do
          expect(subject).to validate_against('pain.008.003.02.xsd')
        end

        it 'should contain <InstrId>' do
          expect(subject).to have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/PmtId/InstrId', '1234/ABC')
        end
      end

      context 'with a different currency given' do
        subject do
          sct = direct_debit

          sct.add_transaction(direct_debt_transaction.merge(instruction: '1234/ABC', currency: 'SEK'))

          sct
        end

        it 'should validate against pain.001.001.03' do
          expect(subject.to_xml(SEPA::PAIN_008_001_02)).to validate_against('pain.008.001.02.xsd')
        end

        it 'should have a CHF Ccy' do
          doc = Nokogiri::XML(subject.to_xml('pain.008.001.02'))
          doc.remove_namespaces!

          nodes = doc.xpath('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/InstdAmt')
          expect(nodes.length).to eql(1)
          expect(nodes.first.attribute('Ccy').value).to eql('SEK')
        end

        it 'should fail for pain.008.002.02' do
          expect {
            subject.to_xml(SEPA::PAIN_008_002_02)
          }.to raise_error(RuntimeError)
        end

        it 'should fail for pain.008.003.02' do
          expect {
            subject.to_xml(SEPA::PAIN_008_003_02)
          }.to raise_error(RuntimeError)
        end
      end
    end
  end
end
