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

  class CreditorIdentifierValidator < ActiveModel::Validator
    def validate(record)
      unless valid?(record.identifier)
        record.errors.add(:identifier, 'is invalid')
      end
    end

    def valid?(identifier)
      if ok = identifier.to_s.match(/[a-zA-Z]{2,2}[0-9]{2,2}([A-Za-z0-9]|[\+|\?|\/|\-|\:|\(|\)|\.|,|']){3,3}([A-Za-z0-9]|[\+|\?|\/|\-|:|\(|\)|\.|,|']){1,28}/)
        # In Germany, the identifier has to be exactly 18 chars long
        if identifier[0..1].match(/DE/i)
          ok = identifier.length == 18
        end
      end
      ok
    end
  end
end
