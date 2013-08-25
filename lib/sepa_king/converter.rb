# encoding: utf-8
module SEPA
  module Converter
    def text_converter(*attributes)
      include InstanceMethods

      attributes.each do |attribute|
        define_method "#{attribute}=" do |value|
          instance_variable_set("@#{attribute}", convert_text(value))
        end
      end
    end

    def decimal_converter(*attributes)
      include InstanceMethods

      attributes.each do |attribute|
        define_method "#{attribute}=" do |value|
          instance_variable_set("@#{attribute}", convert_decimal(value))
        end
      end
    end

    module InstanceMethods
      def convert_text(value)
        return unless value

        text = value.to_s.
          # Convert german umlauts
          gsub('Ä', 'AE').
          gsub('Ü', 'UE').
          gsub('Ö', 'OE').
          gsub('ä', 'ae').
          gsub('ü', 'ue').
          gsub('ö', 'oe').
          gsub('ß', 'ss')

        I18n.transliterate(text).
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
