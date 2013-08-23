# encoding: utf-8
require 'spec_helper'

describe SEPA::CreditTransfer do
  it 'should create valid XML file' do
    ct = SEPA::CreditTransfer.new :name       => 'Schuldner GmbH',
                                  :bic        => 'BANKDEFFXXX',
                                  :iban       => 'DE87200500001234567890'

    ct.add_transaction :name                   => 'Telekomiker AG',
                       :iban                   => 'DE37112589611964645802',
                       :bic                    => 'PBNKDEFF370',
                       :amount                 => 102.50,
                       :reference              => 'XYZ-1234/123',
                       :remittance_information => 'Rechnung vom 22.08.2013'

    ct.add_transaction :name                   => 'Amazonas GmbH',
                       :iban                   => 'DE27793589132923472195',
                       :bic                    => 'TUBDDEDDXXX',
                       :amount                 => 59.00,
                       :reference              => 'XYZ-5678/456',
                       :remittance_information => 'Rechnung om 21.08.2013'

    XML::Document.string(ct.to_xml).should validate_against('pain.001.002.03.xsd')
  end
end
