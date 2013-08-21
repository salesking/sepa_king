# encoding: utf-8
require 'spec_helper'

describe SEPA::Booking do

  before :each do
    @account = SEPA::Account.new(receiver_opts)
  end

  it "should have no rounding error for string" do
    booking = SEPA::Booking.new(@account, "159.73")
    booking.value.should == 15973
  end

  it "should raise if initialized without an account" do
    lambda{ SEPA::Booking.new("account", Date.today) }.should raise_error(SEPA::Exception)
  end

  it "should raise if initialized with wrong value type" do
    lambda{ SEPA::Booking.new(@account, Date.today) }.should raise_error(SEPA::Exception)
  end

  it "should raise if initialized with 0 value" do
    lambda{ SEPA::Booking.new(@account, 0) }.should raise_error(SEPA::Exception)
    lambda{ SEPA::Booking.new(@account, 0.00) }.should raise_error(SEPA::Exception)
  end

  it "should set pos to false with negative value" do
    b = SEPA::Booking.new(@account, -1)
    b.value.should == 100
    b.should_not be_pos
  end

  it "should have no rounding error for float" do
    booking = SEPA::Booking.new(@account, 159.73)
    booking.value.should == 15973
  end
end