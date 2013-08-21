# encoding: utf-8
class SEPA::Base
  @@attribute_defs = Hash.new { |h,k| h[k] = {} }

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

  def self.attribute_defs
    @@attribute_defs[self]
  end

  def self.attribute_defs=(arg)
    @@attribute_defs[self] = arg
  end

  def self.attribute(name, tag, type=:string, member_type=nil, options={})
    if type == :[]
      array_attribute(name, tag, member_type, options)
    elsif type.is_a?(Class) && type != Time && type != Date
      typed_attribute(name, tag, type, options)
    else
      attr_accessor name
      attribute_defs[name] = { :tag => tag, :type => type, :options => options }
    end
  end

  def self.typed_attribute(name, tag, type, options)
    attribute_defs[name] = { :tag => tag, :type => type, :options => options }
    attr_accessor name
  end

  def self.array_attribute(name, tag, member_type=nil, options={})
    attribute_defs[name] = { :tag => tag, :type => :[], :member_type => member_type, :options => options }
    attr_accessor name
  end
end
