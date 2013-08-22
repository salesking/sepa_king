# encoding: utf-8
require 'spec_helper'

describe SEPA::DirectDebitInitiation do
  it 'should create valid XML file' do
    ddi = SEPA::DirectDebitInitiation.new :name       => 'Gläubiger GmbH',
                                          :bic        => 'BANKDEFFXXX',
                                          :iban       => 'DE87200500001234567890',
                                          :identifier => 'DE98ZZZ09999999999'

    ddi.add_transaction :name                      => 'Zahlemann & Söhne GbR',
                        :iban                      => 'DE21500500009876543210',
                        :bic                       => 'SPUEDE2UXXX',
                        :amount                    => 39.99,
                        :mandate_id                => 'K-02-2011-12345',
                        :mandate_date_of_signature => Date.new(2011,01,25)

    XML::Document.string(ddi.generate_xml).should validate_against('pain.008.002.02.xsd')
  end
end
