# encoding: utf-8
require 'spec_helper'

describe SEPA::Helper do
  include SEPA::Helper

  it "should convert to upper case" do
    convert_text('2&2 GmbH & Co. KG').should == '2&2 GMBH & CO. KG'
  end

  it "should remove invalid chars" do
    convert_text('@()"=<>!§').should == ''
  end

  it "should leave valid chars" do
    convert_text('abc-ABC-0123- .,&/+*$%').should == 'ABC-ABC-0123- .,&/+*$%'
  end

  it "should convert umlaute" do
    convert_text('üöäÜÖÄß').should == 'UEOEAEUEOEAESS'
  end
end
