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

        value.to_s.
          # Replace some special characters described as "Best practices" in Chapter 6.2 of this document:
          # http://www.europeanpaymentscouncil.eu/index.cfm/knowledge-bank/epc-documents/sepa-requirements-for-an-extended-character-set-unicode-subset-best-practices/
          gsub('€','E').
          gsub('@','(at)').
          gsub('_','-').

          # Replace linebreaks by spaces
          gsub(/\n+/,' ').

          # Remove all invalid characters
          gsub(/[^a-zA-Z0-9ÄÖÜäöüß&*$%\ \'\:\?\,\-\(\+\.\)\/]/, '').

          # Remove leading and trailing spaces
          strip
      end

      def convert_decimal(value)
        return unless value
        value = begin
          BigDecimal(value.to_s)
        rescue ArgumentError
        end

        if value && value.finite? && value > 0
          value.round(2)
        end
      end
    end
  end
end
