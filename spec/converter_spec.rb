# encoding: utf-8
require 'spec_helper'

describe SEPA::Converter do
  include SEPA::Converter::InstanceMethods

  describe :convert_text do
    it 'should convert special chars' do
      expect(convert_text('10€')).to eq('10E')
      expect(convert_text('info@bundesbank.de')).to eq('info(at)bundesbank.de')
      expect(convert_text('abc_def')).to eq('abc-def')
    end

    it 'should not change allowed special character' do
      expect(convert_text('üöäÜÖÄß')).to eq('üöäÜÖÄß')
      expect(convert_text('&*$%')).to eq('&*$%')
    end

    it 'should convert line breaks' do
      expect(convert_text("one\ntwo"))    .to eq('one two')
      expect(convert_text("one\ntwo\n"))  .to eq('one two')
      expect(convert_text("\none\ntwo\n")).to eq('one two')
      expect(convert_text("one\n\ntwo"))  .to eq('one two')
    end

    it 'should convert number' do
      expect(convert_text(1234)).to eq('1234')
    end

    it 'should remove invalid chars' do
      expect(convert_text('"=<>!')).to eq('')
    end

    it 'should not touch valid chars' do
      expect(convert_text("abc-ABC-0123- ':?,-(+.)/")).to eq("abc-ABC-0123- ':?,-(+.)/")
    end

    it 'should not touch nil' do
      expect(convert_text(nil)).to eq(nil)
    end
  end

  describe :convert_decimal do
    it "should convert Integer to BigDecimal" do
      expect(convert_decimal(42)).to eq(BigDecimal('42.00'))
    end

    it "should convert Float to BigDecimal" do
      expect(convert_decimal(42.12)).to eq(BigDecimal('42.12'))
    end

    it 'should round' do
      expect(convert_decimal(1.345)).to eq(BigDecimal('1.35'))
    end

    it 'should not touch nil' do
      expect(convert_decimal(nil)).to eq(nil)
    end

    it 'should not convert zero value' do
      expect(convert_decimal(0)).to eq(nil)
    end

    it 'should not convert negative value' do
      expect(convert_decimal(-3)).to eq(nil)
    end

    it 'should not convert invalid value' do
      expect(convert_decimal('xyz')).to eq(nil)
      expect(convert_decimal('NaN')).to eq(nil)
      expect(convert_decimal('Infinity')).to eq(nil)
    end
  end
end
