# encoding: utf-8
require 'spec_helper'

describe SEPA::CreditTransferTransaction do
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
      it 'should success' do
        SEPA::CreditTransferTransaction.new({}).should be_schema_compatible('pain.001.003.03')
      end
    end

    context 'pain.001.002.03' do
      it 'should success for valid attributes' do
        SEPA::CreditTransferTransaction.new(:bic => 'SPUEDE2UXXX', :service_level => 'SEPA').should be_schema_compatible('pain.001.002.03')
      end

      it 'should fail for invalid attributes' do
        SEPA::CreditTransferTransaction.new(:bic => nil).should_not be_schema_compatible('pain.001.002.03')
        SEPA::CreditTransferTransaction.new(:bic => 'SPUEDE2UXXX', :service_level => 'URGP').should_not be_schema_compatible('pain.001.002.03')
      end
    end
  end

  context 'Requested date' do
    it 'should allow valid value' do
      SEPA::CreditTransferTransaction.should accept(nil, Date.today, Date.today.next, Date.today + 2, for: :requested_date)
    end

    it 'should not allow invalid value' do
      SEPA::CreditTransferTransaction.should_not accept(Date.new(1995,12,21), Date.today - 1, for: :requested_date)
    end
  end
end
