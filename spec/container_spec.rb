# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SEPA::Container do
  let(:sender_id) do
    'ABCDEFGH'
  end

  let(:id_type) do
    'EBIC'
  end

  let(:container) do
    SEPA::Container.new(
      sender_id: sender_id,
      id_type:   id_type,
    )
  end

  let(:valid_sct) do
    sct = SEPA::CreditTransfer.new(
            name: 'Schuldner GmbH',
            bic:  'BANKDEFFXXX',
            iban: 'DE87200500001234567890',
          )

    sct.add_transaction(
      name:                   'Telekomiker AG',
      bic:                    'PBNKDEFF370',
      iban:                   'DE37112589611964645802',
      amount:                 102.50,
      currency:               'EUR',
      instruction:            '12345',
      reference:              'XYZ-1234/123',
      remittance_information: 'Rechnung',
      requested_date:         Date.today,
    )

    sct
  end

  let(:valid_sdd) do
    sdd = SEPA::DirectDebit.new(
            name:                'Gläubiger GmbH',
            bic:                 'BANKDEFFXXX',
            iban:                'DE87200500001234567890',
            creditor_identifier: 'DE98ZZZ09999999999',
          )

    sdd.add_transaction(
      name:                      'Zahlemann & Söhne GbR',
      bic:                       'SPUEDE2UXXX',
      iban:                      'DE21500500009876543210',
      amount:                    39.99,
      currency:                  'EUR',
      instruction:               '12345',
      reference:                 'XYZ/2013-08-ABO/6789',
      remittance_information:    'Vielen Dank für Ihren Einkauf!',
      mandate_id:                'K-02-2011-12345',
      mandate_date_of_signature: Date.today,
      local_instrument:          'CORE',
      sequence_type:             'FRST',
      requested_date:            nil,
    )

    sdd
  end

  let(:invalid_sct) do
    sct = SEPA::CreditTransfer.new(
            name: 'Schuldner GmbH',
          )

    sct.add_transaction(
      name:                   'Telekomiker AG',
      bic:                    'PBNKDEFF370',
      iban:                   'DE37112589611964645802',
      amount:                 102.50,
      currency:               'EUR',
      instruction:            '12345',
      reference:              'XYZ-1234/123',
      remittance_information: 'Rechnung',
      requested_date:         Date.today,
    )

    sct
  end

  describe 'validation' do

    context 'with invalid sender_id' do
      let(:sender_id) do
        'A' * 23
      end

      it 'is invalid' do
        expect(container.valid?).to eq(false)
        expect(container.errors_on(:sender_id).size).to eq(1)
      end
    end

    context 'with invalid id_type' do
      let(:id_type) do
        nil
      end

      it 'is invalid' do
        expect(container.valid?).to eq(false)
        expect(container.errors_on(:id_type).size).to eq(1)
      end
    end

    context 'without any message' do
      it 'is invalid' do
        expect(container.valid?).to eq(false)
        expect(container.errors_on(:messages).size).to eq(1)
      end
    end

    context 'with an invalid message' do
      before do
        container.add_message(invalid_sct)
      end

      it 'is invalid' do
        expect(container.valid?).to eq(false)
        expect(container.errors_on(:messages).size).to eq(1)
      end
    end

    context 'with a mix of message types' do
      before do
        container.add_message(valid_sct)
        container.add_message(valid_sdd)
      end

      it 'is invalid' do
        expect(container.valid?).to eq(false)
        expect(container.errors_on(:messages).size).to eq(1)
      end
    end

  end

  describe '#creation_date_time' do
    it 'returns Time.now.iso8601' do
      expect(container.creation_date_time).to eq(Time.now.iso8601)
    end
  end

  describe '#add_message' do
    it 'adds valid messages' do
      3.times do
        container.add_message(valid_sct)
      end

      expect(container.messages.size).to eq(3)
    end
  end

  describe '#validate_final_document!' do
    let(:document) do
      Nokogiri::XML.parse('<not-valid></not-valid>')
    end

    before do
      container.add_message(valid_sct)
    end

    it 'fails' do
      expect do
        container.validate_final_document!(document, 'container.nnn.001.04')
      end.to raise_error(SEPA::Error, /Incompatible with schema/)
    end
  end

  describe '#to_xml' do
    context 'with an invalid message' do
      before do
        container.add_message(invalid_sct)
      end

      it 'fails' do
        expect do
          container.to_xml
        end.to raise_error(SEPA::Error, 'Messages is invalid')
      end
    end

    context 'with valid message' do
      context 'with an unknown schema' do
        before do
          container.add_message(valid_sct)
        end

        it 'fails' do
          expect do
            container.to_xml('pain.001.001.03')
          end.to raise_error(ArgumentError, 'Schema pain.001.001.03 is unknown!')
        end
      end

      context 'with an incompatible schema' do
        before do
          container.add_message(valid_sct)

          expect(container)
            .to receive(:schema_compatible?)
                  .and_return(false)
        end

        it 'fails' do
          expect do
            container.to_xml
          end.to raise_error(SEPA::Error, 'Incompatible with schema container.nnn.001.GBIC4!')
        end
      end

      context 'with credit transfers' do
        before do
          container.add_message(valid_sct)
        end

        it 'is valid against the container schema container.nnn.001.04' do
          expect(container.to_xml(SEPA::CONTAINER_NNN_001_04))
            .to validate_against('container.nnn.001.04.xsd')
        end

        it 'is valid against the container schema container.nnn.001.GBIC4' do
          expect(container.to_xml(SEPA::CONTAINER_NNN_001_GBIC4))
            .to validate_against('container.nnn.001.GBIC4.xsd')
        end

        it 'is valid against the container schema container.nnn.001.02' do
          expect(container.to_xml(SEPA::CONTAINER_NNN_001_02))
            .to validate_against('container.nnn.001.02.xsd')
        end
      end

      context 'with direct debits' do
        before do
          container.add_message(valid_sdd)
        end

        it 'is valid against the container schema container.nnn.001.04' do
          expect(container.to_xml(SEPA::CONTAINER_NNN_001_04))
            .to validate_against('container.nnn.001.04.xsd')
        end

        it 'is valid against the container schema container.nnn.001.GBIC4' do
          expect(container.to_xml(SEPA::CONTAINER_NNN_001_GBIC4))
            .to validate_against('container.nnn.001.GBIC4.xsd')
        end

        it 'is valid against the container schema container.nnn.001.02' do
          expect(container.to_xml(SEPA::CONTAINER_NNN_001_02))
            .to validate_against('container.nnn.001.02.xsd')
        end
      end
    end
  end

end
