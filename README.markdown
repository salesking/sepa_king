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
* works with ruby 1.9.2

## TODOs

* get started

## Resources

* SalesKing: http://salesking.eu

## Examples

How to create a SEPA File. Also check out the specs to have a running example of an export.

### DTA

```ruby
# create a new dtaus object
dta = SEPA::Dtaus.new('LK')

# set sender account
dta.account = SEPA::Account.new(
                    :bank_account_number => "123456789",
                    :bank_number => "69069096",
                    :owner_name => "Return to Sender",
                    :bank_name => "Money Burner Bank")

# following should be done in a loop to add multiple bookings
# create receiving account
receiver = SEPA::Account.new(
                    :bank_account_number => "987456123",
                    :bank_number => "99099096",
                    :owner_name => "Gimme More Lt.",
                    :bank_name => "Banking Bandits")
# create booking
booking = SEPA::Booking.new(receiver, 100.00 )

# set booking text if you want to
booking.text = "Thanks for your purchase"

# add booking
dta.add( booking )
# end loop

# create datausstring and do with it whatever fits your workflow
my_str = dta.create

```

also make sure to read the code and the specs

## Credits



Copyright (c) 20013 Georg Leciejewski (SalesKing), Georg Ledermann (https://github.com/ledermann) released under the MIT license
