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
end
