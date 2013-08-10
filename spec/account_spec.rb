# encoding: utf-8
require 'spec_helper'

describe Sepa::Account do

  before :each do
    @ba = test_kto2 # BankAccount mocked as open struct
  end

  it "should initialize a new account" do
    lambda{
      Sepa::Account.new(:bank_account_number => @ba.bank_account_number,
                           :bank_number => @ba.bank_number,
                           :owner_name => @ba.owner_name)
    }.should_not raise_error
  end

  # Sepa::Acount.new tends to remove keys from supplied hashes, which breaks
  # things when I create multiple DTAUS files at once.
  it "should not remove data from hashes" do
    sender = {:owner_street => "123 Random Street",
              :bank_account_number => @ba.bank_account_number,
              :bank_number => @ba.bank_number,
              :owner_name => @ba.owner_name}

    sender.keys.should include(:owner_street) # => true
    Sepa::Account.new(sender)
    sender.keys.should include(:owner_street) # => boom!
  end

  it "should initialize a new dtazv account" do
    lambda{
      Sepa::Account.new(sender_opts)
    }.should_not raise_error
  end

  it "should convert bank_account_number to integer" do
    opts = {:bank_account_number => '0123456',
             :bank_number => @ba.bank_number,
             :owner_name => @ba.owner_name}
    anct = Sepa::Account.new(opts)
    anct.bank_account_number.should == 123456

    anct2 = Sepa::Account.new(opts.merge(:bank_account_number=>'012 345 6'))
    anct2.bank_account_number.should == 123456
  end

  it "should convert bank_number to integer" do
    opts = {:bank_account_number => @ba.bank_account_number,
             :bank_number => '0123',
             :owner_name => @ba.owner_name}
    anct = Sepa::Account.new(opts)
    anct.bank_number.should == 123

    anct2 = Sepa::Account.new(opts.merge(:bank_number=>'012 34 5'))
    anct2.bank_number.should == 12345
  end

  it "should fail if bank account number is invalid" do
    lambda{
      Sepa::Account.new(:bank_account_number => 123456789011123456789011123456789011,
                           :bank_number => @ba.bank_number,
                           :owner_name => @ba.owner_name)

    }.should raise_error(ArgumentError, 'Bank account number too long, max 10 allowed')
  end

  it "should fail if bank number is invalid" do
    lambda{
      Sepa::Account.new( :bank_account_number => @ba.bank_account_number,
                            :bank_number => 0,
                            :owner_name => @ba.owner_name)
    }.should raise_error(ArgumentError)

    lambda{
      Sepa::Account.new( :bank_account_number => @ba.bank_account_number,
                            :bank_number => 123456789101112,
                            :owner_name => @ba.owner_name)
    }.should raise_error(ArgumentError, 'Bank number too long, max 8 allowed')
  end

  it "should fail if owner number is too long" do
    lambda{
      Sepa::Account.new( :bank_account_number => @ba.bank_account_number,
                            :bank_number => @ba.bank_number,
                            :owner_name => @ba.owner_name,
                            :owner_number => 12345678901)
    }.should raise_error(ArgumentError, 'Owner number too long, max 10 allowed')
  end

  it "should fail if street and/or Zip Code is too long" do
    opts = sender_opts.merge( :bank_street => "Lorem ipsum dolor sit amet, consectetur")
    lambda{
      Sepa::Account.new(opts)
    }.should raise_error(ArgumentError, 'Bank street too long, max 35 allowed')
  end

  it "should fail if city is too long" do
    opts = sender_opts.merge( :bank_city => "Lorem ipsum dolor sit amet, consecte")
    lambda{
      Sepa::Account.new opts
    }.should raise_error(ArgumentError, 'Bank city too long, max 35 allowed')
  end

  it "should fail if bank name is too long" do
    opts = sender_opts.merge( :bank_name => "Lorem ipsum dolor sit amet, consecte")
    lambda{
      Sepa::Account.new opts
    }.should raise_error(ArgumentError, 'Bank name too long, max 35 allowed')
  end

  it "should fail if client street is too long" do
    opts = sender_opts.merge( :owner_street => "Lorem ipsum dolor sit amet, consecte")
    lambda{
      Sepa::Account.new opts
    }.should raise_error(ArgumentError, 'Owner street too long, max 35 allowed')
  end

  it "should fail if city is too long" do
    opts = sender_opts.merge( :owner_city => "Lorem ipsum dolor sit amet, consecte")
    lambda{
      Sepa::Account.new opts
    }.should raise_error(ArgumentError, 'Owner city too long, max 35 allowed')
  end

  it "should return account street and zip" do
    acnt = Sepa::Account.new( sender_opts )
    acnt.bank_zip_city.should == "51063 BANK KOELN"
  end

  it "should return sender street and zip" do
    acnt = Sepa::Account.new( sender_opts )
    acnt.owner_zip_city.should == "51063 MEINE KOELN"
  end

  it "should set owner country code from iban" do
    opts = receiver_opts
    opts[:owner_country_code] = nil
    acnt = Sepa::Account.new( opts )
    acnt.owner_country_code.should == "PL"
  end
end
