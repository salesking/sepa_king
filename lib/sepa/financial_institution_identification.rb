# encoding: utf-8
require 'sepa/base'

# eindeutige Identifikation eines Kreditinstituts
class SEPA::FinancialInstitutionIdentification < SEPA::Base
  # Business Identifier Code (SWIFT-Code)
  attribute :bic, 'BIC'
end
