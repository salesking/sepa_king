# encoding: utf-8
require 'spec_helper'

RSpec.describe SEPA::CreditTransferTransaction do
  describe :initialize do
    it 'should initialize a valid transaction' do
      expect(
        SEPA::CreditTransferTransaction.new name:                   'Telekomiker AG',
                                            iban:                   'DE37112589611964645802',
                                            bic:                    'PBNKDEFF370',
                                            amount:                 102.50,
                                            reference:              'XYZ-1234/123',
                                            remittance_information: 'Rechnung 123 vom 22.08.2013'
      ).to be_valid
    end
  end

  describe :schema_compatible? do
    context 'for pain.001.003.03' do
      it 'should succeed' do
        expect(SEPA::CreditTransferTransaction.new({})).to be_schema_compatible('pain.001.003.03')
      end

      it 'should fail for invalid attributes' do
        expect(SEPA::CreditTransferTransaction.new(:currency => 'CHF')).not_to be_schema_compatible('pain.001.003.03')
      end
    end

    context 'pain.001.002.03' do
      it 'should succeed for valid attributes' do
        expect(SEPA::CreditTransferTransaction.new(:bic => 'SPUEDE2UXXX', :service_level => 'SEPA')).to be_schema_compatible('pain.001.002.03')
      end

      it 'should fail for invalid attributes' do
        expect(SEPA::CreditTransferTransaction.new(:bic => nil)).not_to be_schema_compatible('pain.001.002.03')
        expect(SEPA::CreditTransferTransaction.new(:bic => 'SPUEDE2UXXX', :service_level => 'URGP')).not_to be_schema_compatible('pain.001.002.03')
        expect(SEPA::CreditTransferTransaction.new(:bic => 'SPUEDE2UXXX', :currency => 'CHF')).not_to be_schema_compatible('pain.001.002.03')
      end
    end

    context 'for pain.001.001.03' do
      it 'should succeed for valid attributes' do
        expect(SEPA::CreditTransferTransaction.new(:bic => 'SPUEDE2UXXX', :currency => 'CHF')).to be_schema_compatible('pain.001.001.03')
        expect(SEPA::CreditTransferTransaction.new(:bic => nil)).to be_schema_compatible('pain.001.003.03')
      end
    end

    context 'for pain.001.001.03.ch.02' do
      it 'should succeed for valid attributes' do
        expect(SEPA::CreditTransferTransaction.new(:bic => 'SPUEDE2UXXX', :currency => 'CHF')).to be_schema_compatible('pain.001.001.03.ch.02')
      end
    end
  end

  context 'Requested date' do
    it 'should allow valid value' do
      expect(SEPA::CreditTransferTransaction).to accept(nil, Date.new(1999, 1, 1), Date.today, Date.today.next, Date.today + 2, for: :requested_date)
    end

    it 'should not allow invalid value' do
      expect(SEPA::CreditTransferTransaction).not_to accept(Date.new(1995,12,21), Date.today - 1, for: :requested_date)
    end
  end

  context 'Category Purpose' do
    it 'should allow valid value' do
      expect(SEPA::CreditTransferTransaction).to accept(nil, 'SALA', 'X' * 4, for: :category_purpose)
    end

    it 'should not allow invalid value' do
      expect(SEPA::CreditTransferTransaction).not_to accept('', 'X' * 5, for: :category_purpose)
    end
  end

  context 'Local Instrument' do
    it 'should allow valid value' do
      expect(SEPA::CreditTransferTransaction).to accept(nil, 'INST', for: :local_instrument)
    end

    it 'should not allow invalid value' do
      expect(SEPA::CreditTransferTransaction).not_to accept('SEPA', 'X' * 5, for: :local_instrument)
    end

    context 'for pain.001.001.03' do
      it 'should be valid' do
        expect(SEPA::CreditTransferTransaction.new(:currency => 'EUR', :local_instrument => 'INST')).to be_schema_compatible('pain.001.001.03')
      end
    end

    context 'for pain.001.002.03' do
      it 'should not be valid' do
        expect(SEPA::CreditTransferTransaction.new(:currency => 'EUR', :local_instrument => 'INST')).not_to be_schema_compatible('pain.001.002.03')
      end
    end

    context 'for pain.001.003.03' do
      it 'should not be valid' do
        expect(SEPA::CreditTransferTransaction.new(:currency => 'EUR', :local_instrument => 'INST')).not_to be_schema_compatible('pain.001.003.03')
      end
    end

    context 'when Local Instrument is INST' do
      context 'when service level is SEPA' do
        it 'should be valid' do
          expect(
            SEPA::CreditTransferTransaction.new name:                   'Telekomiker AG',
                                                iban:                   'FR7630003012340001234567854',
                                                bic:                    'SOGEFRPP',
                                                amount:                 406.57,
                                                currency:               'EUR',
                                                service_level:          'SEPA',
                                                reference:              'XYZ-1234/123',
                                                remittance_information: 'Rechnung 123 vom 22.08.2013',
                                                local_instrument:       'INST'
          ).to be_valid
        end
      end

      context 'when currency is EUR' do
        it 'should be valid' do
          expect(
            SEPA::CreditTransferTransaction.new name:                   'Telekomiker AG',
                                                iban:                   'FR7630003012340001234567854',
                                                bic:                    'SOGEFRPP',
                                                amount:                 142.50,
                                                currency:               'EUR',
                                                reference:              'XYZ-1234/123',
                                                remittance_information: 'Rechnung 123 vom 22.08.2013',
                                                local_instrument:       'INST'
          ).to be_valid
        end
      end

      context 'when service level is URGP' do
        subject {
          SEPA::CreditTransferTransaction.new name:                   'Telekomiker AG',
                                              iban:                   'FR7630003012340001234567854',
                                              bic:                    'SOGEFRPP',
                                              amount:                 102.53,
                                              reference:              'XYZ-1234/123',
                                              remittance_information: 'Rechnung 123 vom 22.08.2013',
                                              local_instrument:       'INST',
                                              service_level:          'URGP'
        }

        it 'should not be valid' do
          expect(subject).not_to be_valid
        end

        it 'returns errors' do
          subject.valid?
          expect(subject.errors_on(:local_instrument).size).to eq(1)
        end
      end
    end
  end
end
