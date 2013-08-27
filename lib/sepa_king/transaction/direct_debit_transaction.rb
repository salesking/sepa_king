# encoding: utf-8
module SEPA
  class DirectDebitTransaction < Transaction
    attr_accessor :mandate_id, :mandate_date_of_signature

    validates_length_of :mandate_id, within: 1..35
    validates_presence_of :mandate_date_of_signature

    validate do |t|
      if t.mandate_date_of_signature.is_a?(Date)
        errors.add(:mandate_date_of_signature, 'is in the future') if t.mandate_date_of_signature > Date.today
      else
        errors.add(:mandate_date_of_signature, 'is not a Date')
      end
    end
  end
end
