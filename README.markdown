# handle SEPA like a King

[![Build Status](https://secure.travis-ci.org/salesking/sepa_king.png)](http://travis-ci.org/salesking/sepa_king)

We love building payment applications! So after developing the best [DTAUS](https://github.com/salesking/king_dtaus) ruby lib we move on with SEPA!

We are starting with parts of our old dtaus lib, so please be patient as we get ready for a release!


## Install

    gem install sepa_king

## Features

* Create debit transfer
* Create credit transfer
* 100% test coverage to ensure software quality
* Tested with Ruby 1.9.3 and 2.0.0

## TODOs

* get started

## Resources

* SalesKing: http://salesking.eu

## Examples

How to create a SEPA File. Also check out the specs to have a running example of an export.

```ruby
# Build a new SEPA file for Direct Debit
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
ddi.add_transaction ...._

# create XML string and do with it whatever fits your workflow
xml_string = ddi.to_xml
```

also make sure to read the code and the specs


## License

Copyright (c) 20013 Georg Leciejewski (SalesKing), Georg Ledermann (https://github.com/ledermann)
Released under the MIT license
