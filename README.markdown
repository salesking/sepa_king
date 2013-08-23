# Handle SEPA like a king

[![Build Status](https://secure.travis-ci.org/salesking/sepa_king.png)](http://travis-ci.org/salesking/sepa_king)
[![Code Climate](https://codeclimate.com/github/salesking/sepa_king.png)](https://codeclimate.com/github/salesking/sepa_king)
[![Coverage Status](https://coveralls.io/repos/salesking/sepa_king/badge.png)](https://coveralls.io/r/salesking/sepa_king)

We love building payment applications! So after developing the [DTAUS library for Ruby](https://github.com/salesking/king_dtaus) we move on with SEPA!

This is just the beginning. There is still a lot to do. Please stay tuned...


## Features

* Credit transfer (pain.001.002.03)
* Debit transfer (pain.008.002.02)
* 100% test coverage to ensure software quality
* Tested with Ruby 1.9.3 and 2.0.0


## Installation

    gem install sepa_king


## Examples

How to create a SEPA file for direct debit ("Lastschrift")

```ruby
# First: Create the main object
dd = SEPA::DirectDebit.new :name       => 'Gläubiger GmbH',
                           :bic        => 'BANKDEFFXXX',
                           :iban       => 'DE87200500001234567890',
                           :identifier => 'DE98ZZZ09999999999'

# Second: Add transactions
dd.add_transaction :name                      => 'Zahlemann & Söhne GbR',
                   :iban                      => 'DE21500500009876543210',
                   :bic                       => 'SPUEDE2UXXX',
                   :amount                    => 39.99,
                   :mandate_id                => 'K-02-2011-12345',
                   :mandate_date_of_signature => Date.new(2011,1,25)
dd.add_transaction ...

# Last: create XML string
xml_string = dd.to_xml
```


How to create a SEPA file for credit transfer ("Überweisung")

```ruby
# First: Create the main object
ct = SEPA::CreditTransfer.new :name       => 'Schuldner GmbH',
                              :bic        => 'BANKDEFFXXX',
                              :iban       => 'DE87200500001234567890'

# Second: Add transactions
ct.add_transaction :name                   => 'Telekomiker AG',
                   :iban                   => 'DE37112589611964645802',
                   :bic                    => 'PBNKDEFF370',
                   :amount                 => 102.50,
                   :reference              => 'XYZ-1234/123',
                   :remittance_information => 'Rechnung vom 22.08.2013'
ct.add_transaction ...

# Last: create XML string
xml_string = ct.to_xml
```

Make sure to read the code and the specs!


## Changelog

https://github.com/salesking/sepa_king/releases


## Resources

* http://www.ebics.de/index.php?id=77
* SalesKing: http://salesking.eu


## License

Released under the MIT license

Copyright (c) 2013 Georg Leciejewski (SalesKing), Georg Ledermann (https://github.com/ledermann)
