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
      require 'csv'

      # ‘.’, a full stop (U+002E) denotes that there is no restricted character
      # set equivalent and hence a full stop is to be used.
      FALLBACK_EPC_CHAR = '.'.freeze
      private_constant :FALLBACK_EPC_CHAR

      EPC_MAPPING = CSV.read("lib/misc/epc_mapping.csv", col_sep: ",").
        each_with_object(Hash.new(FALLBACK_EPC_CHAR)) { |v, mappings| mappings[v.first] = v.last }.
        freeze
      private_constant :EPC_MAPPING

      def convert_text(value)
        return value unless value.present?

        # Map chars according to:
        # http://www.europeanpaymentscouncil.eu/index.cfm/knowledge-bank/epc-documents/sepa-requirements-for-an-extended-character-set-unicode-subset-best-practices/
        value.to_s.gsub(/\n+/,' ').each_char.map { |c| EPC_MAPPING[c] }.join.strip
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
