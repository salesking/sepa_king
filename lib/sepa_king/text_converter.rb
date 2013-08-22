# encoding: utf-8
module SEPA
  module TextConverter
    def convert_text(text)
      text = text.to_s
      return text if text.empty?

      text = text.
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
  end
end
