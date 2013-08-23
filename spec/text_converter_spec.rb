# encoding: utf-8
require 'spec_helper'

describe SEPA::TextConverter do
  include SEPA::TextConverter

  it "should convert to upper case" do
    convert_text('2&2 GmbH & Co. KG').should == '22 GmbH  Co. KG'
  end

  it "should remove invalid chars" do
    convert_text('&@"=<>!').should == ''
  end

  it "should leave valid chars" do
    convert_text("abc-ABC-0123- ':?,-(+.)/").should == "abc-ABC-0123- ':?,-(+.)/"
  end

  it "should convert umlaute" do
    convert_text('üöäÜÖÄß').should == 'ueoeaeUEOEAEss'
  end
end
