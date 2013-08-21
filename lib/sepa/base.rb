# encoding: utf-8
class SEPA::Base
  def self.attribute(name, tag, type=:string, member_type=nil, options={}, &block)
    attribute_defs[name] = { :tag => tag, :type => type, :member_type => member_type, :options => options, :block => block }

    if block_given?
      define_method name do
        block.call(self)
      end
    else
      attr_accessor name
    end

    (options[:attributes] || {}).each_pair do |k,v|
      attr_accessor v
    end
  end

  @@attribute_defs = Hash.new { |h,k| h[k] = {} }

  def self.attribute_defs
    @@attribute_defs[self]
  end

  def self.attribute_defs=(arg)
    @@attribute_defs[self] = arg
  end

  def initialize(options={})
    options.each_pair do |k,v|
      self.send("#{k}=", v)
    end
  end

  def to_xml(builder)
    self.class.attribute_defs.each do |name, meta|
      item = self.send(name)
      options = meta[:options] || {}
      attributes = build_xml_attributes(options[:attributes])
      next if item == nil
      if meta[:type] == :string
        builder.__send__(meta[:tag], item, attributes)
      elsif meta[:type] == :[]
        if meta[:member_type] == nil
          item.each { |obj| builder.__send__(meta[:tag], obj, attributes) }
        else
          item.each do |obj|
            builder.__send__(meta[:tag], attributes) { obj.to_xml builder }
          end
        end
      elsif meta[:type] == Time
        v = item.is_a?(String) ? item : item.strftime("%Y-%m-%dT%H:%M:%S")
        builder.__send__(meta[:tag], v, attributes)
      elsif meta[:type] == Date
        v = item.is_a?(String) ? item : item.strftime("%Y-%m-%d")
        builder.__send__(meta[:tag], v, attributes)
      elsif meta[:type].is_a? Class
        builder.__send__(meta[:tag], attributes) { item.to_xml builder }
      end
    end
  end

private

  def build_xml_attributes(names)
    result = {}
    (names || {}).each { |k,v|
      result[k] = self.send v
    }
    result
  end
end
