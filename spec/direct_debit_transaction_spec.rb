# encoding: utf-8
require 'spec_helper'

describe SEPA::DirectDebitTransaction do
  describe :initialize do
    it 'should create a valid transaction' do
      expect(
        SEPA::DirectDebitTransaction.new name:                      'Zahlemann & Söhne Gbr',
                                         bic:                       'SPUEDE2UXXX',
                                         iban:                      'DE21500500009876543210',
                                         amount:                    39.99,
                                         reference:                 'XYZ-1234/123',
                                         remittance_information:    'Vielen Dank für Ihren Einkauf!',
                                         mandate_id:                'K-02-2011-12345',
                                         mandate_date_of_signature: Date.new(2011,1,25)
      ).to be_valid
    end
  end

  describe :schema_compatible? do
    context 'for pain.008.003.02' do
      it 'should success' do
        SEPA::DirectDebitTransaction.new({}).should be_schema_compatible('pain.008.003.02')
      end
    end

    context 'for pain.008.002.02' do
      it 'should success for valid attributes' do
        SEPA::DirectDebitTransaction.new(:bic => 'SPUEDE2UXXX', :local_instrument => 'CORE').should be_schema_compatible('pain.008.002.02')
      end

      it 'should fail for invalid attributes' do
        SEPA::DirectDebitTransaction.new(:bic => nil).should_not be_schema_compatible('pain.008.002.02')
        SEPA::DirectDebitTransaction.new(:bic => 'SPUEDE2UXXX', :local_instrument => 'COR1').should_not be_schema_compatible('pain.008.002.02')
      end
    end
  end

  context 'Mandate Date of Signature' do
    it 'should accept valid value' do
      SEPA::DirectDebitTransaction.should accept(Date.today, Date.today - 1, for: :mandate_date_of_signature)
    end

    it 'should not accept invalid value' do
      SEPA::DirectDebitTransaction.should_not accept(nil, '2010-12-01', Date.today + 1, for: :mandate_date_of_signature)
    end
  end

  context 'Mandate ID' do
    it 'should allow valid value' do
      SEPA::DirectDebitTransaction.should accept('XYZ-123', "+?/-:().,'", 'X' * 35, for: :mandate_id)
    end

    it 'should not allow invalid value' do
      SEPA::DirectDebitTransaction.should_not accept(nil, '', 'X' * 36, 'ABC 123', '#/*', 'Ümläüt', for: :mandate_id)
    end
  end

  context 'Requested date' do
    it 'should allow valid value' do
      SEPA::DirectDebitTransaction.should accept(nil, Date.today.next, Date.today + 2, for: :requested_date)
    end

    it 'should not allow invalid value' do
      SEPA::DirectDebitTransaction.should_not accept(Date.new(1995,12,21), Date.today - 1, Date.today, for: :requested_date)
    end
  end
end
