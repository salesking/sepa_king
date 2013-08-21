# encoding: utf-8
require 'sepa/base'
require 'sepa/financial_institution_identification'

class SEPA::BranchAndFinancialInstitutionIdentification < SEPA::Base
  # eindeutige Identifikation eines Kreditinstituts
  attribute :financial_institution_identification, "FinInstnId", SEPA::FinancialInstitutionIdentification
end
