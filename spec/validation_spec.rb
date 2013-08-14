require 'spec_helper'

describe 'Credit Transfer Initiation' do
  it "should validate example file" do
    XML::Document.file('spec/fixtures/pain.001.002.03.xml').should validate_against('pain.001.002.03.xsd')
  end
end

describe 'Direct Debit Initiation' do
  it 'should validate example file' do
    XML::Document.file('spec/fixtures/pain.008.002.02.xml').should validate_against('pain.008.002.02.xsd')
  end
end

describe 'Payment Status Report' do
  it "should validate example file" do
    XML::Document.file('spec/fixtures/pain.002.002.03.xml').should validate_against('pain.002.002.03.xsd')
  end
end
