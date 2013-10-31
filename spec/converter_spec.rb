# encoding: utf-8
require 'spec_helper'

describe SEPA::Converter do
  include SEPA::Converter::InstanceMethods

  describe :convert_text do
    it 'should remove invalid chars' do
      convert_text('&@"=<>!').should == ''
    end

    it 'should not touch valid chars' do
      convert_text("abc-ABC-0123- ':?,-(+.)/").should == "abc-ABC-0123- ':?,-(+.)/"
    end

    it 'should convert umlaute' do
      convert_text('üöäÜÖÄß').should == 'ueoeaeUEOEAEss'
    end

    it 'should convert line breaks' do
      convert_text("one\ntwo")    .should == 'one two'
      convert_text("one\ntwo\n")  .should == 'one two'
      convert_text("\none\ntwo\n").should == 'one two'
      convert_text("one\n\ntwo")  .should == 'one two'
    end

    it 'should convert number' do
      convert_text(1234).should == '1234'
    end

    it 'should not touch nil' do
      convert_text(nil).should == nil
    end
  end

  describe :convert_decimal do
    it "should convert Integer to BigDecimal" do
      convert_decimal(42).should == BigDecimal('42.00')
    end

    it "should convert Float to BigDecimal" do
      convert_decimal(42.12).should == BigDecimal('42.12')
    end

    it 'should round' do
      convert_decimal(1.345).should == BigDecimal('1.35')
    end

    it 'should not touch nil' do
      convert_decimal(nil).should == nil
    end
  end
end
