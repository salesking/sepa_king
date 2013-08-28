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

RSpec::Matchers.define :accept do |*values, options|
  attribute = options[:for]

  match_for_should do |actual|
    values.all? { |value|
      expect(
        actual.new(attribute => value)
      ).to have(:no).errors_on(attribute)
    }
  end

  match_for_should_not do |actual|
    values.all? { |value|
      expect(
        actual.new(attribute => value)
      ).to have_at_least(1).errors_on(attribute)
    }
  end
end
