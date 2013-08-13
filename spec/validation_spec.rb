require 'spec_helper'

describe 'Credit Transfer Initiation' do
  it "should validate example file" do
    validate('pain.001.002.03.xsd', 'pain.001.002.03.xml')
  end
end

describe 'Direct Debit Initiation' do
  it 'should validate example file' do
    validate('pain.008.002.02.xsd', 'pain.008.002.02.xml')
  end
end

describe 'Payment Status Report' do
  it "should validate example file" do
    validate('pain.002.002.03.xsd', 'pain.002.002.03.xml')
  end
end

def validate(xsd_filename, xml_filename)
  schema_doc = XML::Document.file("spec/fixtures/#{xsd_filename}")
  schema = XML::Schema.document(schema_doc)
  xml_doc = XML::Document.file("spec/fixtures/#{xml_filename}")

  xml_doc.validate_schema(schema).should be_true
end
