require 'spec_helper'

describe 'Credit Transfer Initiation' do
  it "should validate example file" do
    expect(File.read('spec/examples/pain.001.002.03.xml')).to validate_against('pain.001.002.03.xsd')
    expect(File.read('spec/examples/pain.001.003.03.xml')).to validate_against('pain.001.003.03.xsd')
  end

  it 'should not validate dummy string' do
    expect('foo').not_to validate_against('pain.001.002.03.xsd')
    expect('foo').not_to validate_against('pain.001.003.03.xsd')
  end
end

describe 'Direct Debit Initiation' do
  it 'should validate example file' do
    expect(File.read('spec/examples/pain.008.002.02.xml')).to validate_against('pain.008.002.02.xsd')
    expect(File.read('spec/examples/pain.008.003.02.xml')).to validate_against('pain.008.003.02.xsd')
  end

  it 'should not validate dummy string' do
    expect('foo').not_to validate_against('pain.008.002.02.xsd')
    expect('foo').not_to validate_against('pain.008.003.02.xsd')
  end
end
