require 'spec_helper'

describe 'Credit Transfer Initiation' do
  it "should validate example file" do
    schema = Nokogiri::XML::Schema(load_fixture('pain.001.002.03.xsd')) { |config| config.strict }
    document = Nokogiri::XML(load_fixture('pain.001.002.03.xml')) { |config| config.strict }
    expect { schema.valid?(document) }.to be_true
  end
end

describe 'Direct Debit Initiation' do
  it 'should validate example file' do
    schema = Nokogiri::XML::Schema(load_fixture('pain.008.002.02.xsd')) { |config| config.strict }
    document = Nokogiri::XML(load_fixture('pain.008.002.02.xml')) { |config| config.strict }
    expect { schema.valid?(document) }.to be_true
  end
end

describe 'Payment Status Report' do
  it "should validate example file" do
    schema = Nokogiri::XML::Schema(load_fixture('pain.002.002.03.xsd')) { |config| config.strict }
    document = Nokogiri::XML(load_fixture('pain.002.002.03.xml')) { |config| config.strict }
    expect { schema.valid?(document) }.to be_true
  end
end
