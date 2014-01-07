require 'spec_helper'

describe 'Credit Transfer Initiation' do
  it "should validate example file" do
    File.read('spec/examples/pain.001.001.03.xml').should validate_against('pain.001.001.03.xsd')
    File.read('spec/examples/pain.001.002.03.xml').should validate_against('pain.001.002.03.xsd')
    File.read('spec/examples/pain.001.003.03.xml').should validate_against('pain.001.003.03.xsd')
  end

  it 'should not validate dummy string' do
    'foo'.should_not validate_against('pain.001.001.03.xsd')
    'foo'.should_not validate_against('pain.001.002.03.xsd')
    'foo'.should_not validate_against('pain.001.003.03.xsd')
  end
end

describe 'Direct Debit Initiation' do
  it 'should validate example file' do
    File.read('spec/examples/pain.008.001.02.xml').should validate_against('pain.008.001.02.xsd')
    File.read('spec/examples/pain.008.002.02.xml').should validate_against('pain.008.002.02.xsd')
    File.read('spec/examples/pain.008.003.02.xml').should validate_against('pain.008.003.02.xsd')
  end

  it 'should not validate dummy string' do
    'foo'.should_not validate_against('pain.008.001.02.xsd')
    'foo'.should_not validate_against('pain.008.002.02.xsd')
    'foo'.should_not validate_against('pain.008.003.02.xsd')
  end
end
