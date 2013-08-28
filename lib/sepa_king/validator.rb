# encoding: utf-8
module SEPA
  class IBANValidator < ActiveModel::Validator
    def validate(record)
      unless IBANTools::IBAN.valid?(record.iban.to_s)
        record.errors.add(:iban, 'is invalid')
      end
    end
  end

  class BICValidator < ActiveModel::Validator
    def validate(record)
      unless record.bic.to_s.match /[A-Z]{6,6}[A-Z2-9][A-NP-Z0-9]([A-Z0-9]{3,3}){0,1}/
        record.errors.add(:bic, 'is invalid')
      end
    end
  end
end
