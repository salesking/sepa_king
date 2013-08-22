# Handle SEPA like a king

[![Build Status](https://secure.travis-ci.org/salesking/sepa_king.png)](http://travis-ci.org/salesking/sepa_king)

We love building payment applications! So after developing the best [DTAUS](https://github.com/salesking/king_dtaus) library for Ruby we move on with SEPA!

This is just the beginning. There is still a lot to do. Please stay tuned...


## Features

* Credit transfer (pain.001.002.03)
* Debit transfer (pain.008.002.02)
* 100% test coverage to ensure software quality
* Tested with Ruby 1.9.3 and 2.0.0


## Installation

    gem install sepa_king


## Examples

How to create a SEPA File:

```ruby
# Build a new SEPA file for Direct Debit (Lastschrift)
ddi = SEPA::DirectDebitInitiation.new :name       => 'Gläubiger GmbH',
                                      :bic        => 'BANKDEFFXXX',
                                      :iban       => 'DE87200500001234567890',
                                      :identifier => 'DE98ZZZ09999999999'

# Add transactions
ddi.add_transaction :name                      => 'Zahlemann & Söhne GbR',
                    :iban                      => 'DE21500500009876543210',
                    :bic                       => 'SPUEDE2UXXX',
                    :amount                    => 39.99,
                    :mandate_id                => 'K-02-2011-12345',
                    :mandate_date_of_signature => Date.new(2011,01,25)
ddi.add_transaction ...

# create XML string and do with it whatever fits your workflow
xml_string = ddi.to_xml
```

Make sure to read the code and the specs!


## Resources

* http://www.ebics.de/index.php?id=77
* SalesKing: http://salesking.eu


## License

Released under the MIT license

Copyright (c) 2013 Georg Leciejewski (SalesKing), Georg Ledermann (https://github.com/ledermann)
