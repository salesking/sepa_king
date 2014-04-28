# encoding: utf-8
module SEPA
  module Converter
    def convert(*attributes, options)
      include InstanceMethods

      method_name = "convert_#{options[:to]}"
      raise ArgumentError.new("Converter '#{options[:to]}' does not exist!") unless InstanceMethods.method_defined?(method_name)

      attributes.each do |attribute|
        define_method "#{attribute}=" do |value|
          instance_variable_set("@#{attribute}", send(method_name, value))
        end
      end
    end

    module InstanceMethods
      def convert_text(value)
        return unless value

        I18n.transliterate(value.to_s).
          # Change linebreaks to whitespaces
          gsub(/\n+/,' ').
          # Remove all invalid characters
          gsub(/[^a-zA-Z0-9\ \'\:\?\,\-\(\+\.\)\/]/, '').
          # Remove leading and trailing spaces
          strip
      end

      def convert_decimal(value)
        return unless value
        BigDecimal(value.to_s).round(2)
      end
    end
  end
end
