require 'rspec/expectations'
require 'nokogiri'

RSpec::Matchers.define :validate_against do |xsd|
  match do |actual|
    @schema = Nokogiri::XML::Schema(File.read("lib/schema/#{xsd}"))
    @doc = Nokogiri::XML(actual)

    @schema.should be_valid(@doc)
  end

  failure_message_for_should do |actual|
    # Return the validation errors as string
    @schema.validate(@doc).join("\n")
  end
end

RSpec::Matchers.define :have_xml do |xpath, text|
  match do |actual|
    doc = Nokogiri::XML(actual)
    doc.remove_namespaces! # so we can use shorter xpath's without any namespace

    nodes = doc.xpath(xpath)
    nodes.should_not be_empty
    if text
      nodes.each do |node|
        node.content.should == text
      end
    end
    true
  end
end
