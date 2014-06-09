require 'rspec/expectations'
require 'nokogiri'

RSpec::Matchers.define :validate_against do |xsd|
  match do |actual|
    @schema = Nokogiri::XML::Schema(File.read("lib/schema/#{xsd}"))
    @doc = Nokogiri::XML(actual)

    expect(@schema).to be_valid(@doc)
  end

  failure_message do |actual|
    # Return the validation errors as string
    @schema.validate(@doc).join("\n")
  end
end

RSpec::Matchers.define :have_xml do |xpath, text|
  match do |actual|
    doc = Nokogiri::XML(actual)
    doc.remove_namespaces! # so we can use shorter xpath's without any namespace

    nodes = doc.xpath(xpath)
    expect(nodes).not_to be_empty
    if text
      nodes.each do |node|
        if text.is_a?(Regexp)
          expect(node.content).to match(text)
        else
          expect(node.content).to eq(text)
        end
      end
    end
    true
  end
end

RSpec::Matchers.define :accept do |*values, options|
  attributes = Array(options[:for])

  attributes.each do |attribute|
    match do |actual|
      values.all? { |value|
        expect(
          actual.new(attribute => value).errors_on(attribute).size
        ).to eq 0
      }
    end
  end

  attributes.each do |attribute|
    match_when_negated do |actual|
      values.all? { |value|
        expect(
          actual.new(attribute => value).errors_on(attribute).size
        ).to be >= 1
      }
    end
  end
end
