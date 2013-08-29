# Ruby gem for creating SEPA XML files

[![Build Status](https://secure.travis-ci.org/salesking/sepa_king.png)](http://travis-ci.org/salesking/sepa_king)
[![Code Climate](https://codeclimate.com/github/salesking/sepa_king.png)](https://codeclimate.com/github/salesking/sepa_king)
[![Coverage Status](https://coveralls.io/repos/salesking/sepa_king/badge.png)](https://coveralls.io/r/salesking/sepa_king)
[![Gem Version](https://badge.fury.io/rb/sepa_king.png)](http://badge.fury.io/rb/sepa_king)
[![Dependency Status](https://gemnasium.com/salesking/sepa_king.png)](https://gemnasium.com/salesking/sepa_king)

We love building payment applications! So after developing the [DTAUS library for Ruby](https://github.com/salesking/king_dtaus) we move on with SEPA.


## Features

* Credit transfer initiation (pain.001.002.03)
* Debit transfer initiation (pain.008.002.02)
* Tested with Ruby 1.9.3 and 2.0.0


## Installation

    gem install sepa_king


## Usage

How to create the XML for **Direct Debit Initiation** (in German: "Lastschriften")

```ruby
# First: Create the main object
sdd = SEPA::DirectDebit.new(
  # Name of the initiating party and creditor, in German: "Auftraggeber"
  # String, max. 70 char
  name:       'Gläubiger GmbH',

  # Business Identifier Code (SWIFT-Code) of the creditor
  # String, 8 or 11 char
  bic:        'BANKDEFFXXX',

  # International Bank Account Number of the creditor
  # String, max. 34 chars
  iban:       'DE87200500001234567890',

  # Creditor Identifier, in German: Gläubiger-Identifikationsnummer
  # String, max. 35 chars
  creditor_identifier: 'DE98ZZZ09999999999'
)

# Second: Add transactions
sdd.add_transaction(
  # Name of the debitor, in German: "Zahlungspflichtiger"
  # String, max. 70 char
  name:                      'Zahlemann & Söhne GbR',

  # Business Identifier Code (SWIFT-Code) of the debitor's account
  # String, 8 or 11 char
  bic:                       'SPUEDE2UXXX',

  # International Bank Account Number of the debitor's account
  # String, max. 34 chars
  iban:                      'DE21500500009876543210',

  # Amount in EUR
  # Number with two decimal digit
  amount:                    39.99,

  # OPTIONAL: End-To-End-Identification, will be submitted to the debitor
  # String, max. 35 char
  reference:                 'XYZ/2013-08-ABO/6789',

  # OPTIONAL: Unstructured remittance Information, in German "Verwendungszweck"
  # String, max. 140 char
  remittance_information:    'Vielen Dank für Ihren Einkauf!',

  # Mandate identifikation, in German "Mandatsreferenz"
  # String, max. 35 char
  mandate_id:                'K-02-2011-12345',

  # Mandate Date of signature, in German "Datum, zu dem das Mandat unterschrieben wurde"
  # Date
  mandate_date_of_signature: Date.new(2011,1,25),

  # Local instrument, in German "Lastschriftart"
  # One of this strings:
  #   'CORE' ("Basis-Lastschrift")
  #   'B2B' ("Firmen-Lastschrift")
  local_instrument: 'CORE',

  # Sequence type
  # One of this strings:
  #   'FRST' ("Erst-Lastschrift")
  #   'RCUR' ("Folge-Lastschrift")
  #   'OOFF' ("Einmalige Lastschrift")
  #   'FNAL' ("Letztmalige Lastschrift")
  sequence_type: 'OOFF',

  # OPTIONAL: Requested collection date, in German "Fälligkeitsdatum der Lastschrift"
  # Date
  requested_date: Date.new(2013,9,5),

  # OPTIONAL: Enables or disables batch booking, in German "Sammelbuchung / Einzelbuchung"
  batch_booking: true
)
sdd.add_transaction ...

# Last: create XML string
xml_string = sdd.to_xml
```


How to create the XML for **Credit Transfer Initiation** (in german: "Überweisungen")

```ruby
# First: Create the main object
sct = SEPA::CreditTransfer.new(
  # Name of the initiating party and debitor, in German: "Auftraggeber"
  # String, max. 70 char
  name: 'Schuldner GmbH',

  # Business Identifier Code (SWIFT-Code) of the debitor
  # String, 8 or 11 char
  bic:  'BANKDEFFXXX',

  # International Bank Account Number of the debitor
  # String, max. 34 chars
  iban: 'DE87200500001234567890'
)

# Second: Add transactions
sct.add_transaction(
  # Name of the creditor, in German: "Zahlungsempfänger"
  # String, max. 70 char
  name:                   'Telekomiker AG',

  # Business Identifier Code (SWIFT-Code) of the creditor's account
  # String, 8 or 11 char
  bic:                    'PBNKDEFF370',

  # International Bank Account Number of the creditor's account
  # String, max. 34 chars
  iban:                   'DE37112589611964645802',

  # Amount in EUR
  # Number with two decimal digit
  amount:                 102.50,

  # OPTIONAL: End-To-End-Identification, will be submitted to the creditor
  # String, max. 35 char
  reference:              'XYZ-1234/123',

  # OPTIONAL: Unstructured remittance Information, in German "Verwendungszweck"
  # String, max. 140 char
  remittance_information: 'Rechnung vom 22.08.2013'
)
sct.add_transaction ...

# Last: create XML string
xml_string = sct.to_xml
```


## Changelog

https://github.com/salesking/sepa_king/releases


## Resources

* http://www.ebics.de/index.php?id=77
* SalesKing: http://salesking.eu


## License

Released under the MIT license

Copyright (c) 2013 Georg Leciejewski (SalesKing), Georg Ledermann (https://github.com/ledermann)
