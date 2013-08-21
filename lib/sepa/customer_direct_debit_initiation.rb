# encoding: utf-8
require 'sepa/base'
require 'sepa/group_header'
require 'sepa/payment_instruction_information'

# Kunden-SEPA-Lastschrifteinzugsauftrag
class SEPA::CustomerDirectDebitInitiation < SEPA::Base
  # Kenndaten, die für alle Transaktionen innerhalb der SEPA-Nachricht gelten
  attribute :group_header                     , 'GrpHdr', SEPA::GroupHeader

  # Satz von Angaben, z. B. Einreicherkonto, Fälligkeitsdatum, welcher für alle Einzeltransaktio nen gilt.
  # Die Payment Instruction Information entspricht einem logischen Sammler innerhalb einer physischen Datei.
  attribute :payment_instruction_information  , 'PmtInf', :[], SEPA::PaymentInstructionInformation

  def generate_xml
    builder = Builder::XmlMarkup.new :indent => 2
    builder.instruct!
    builder.Document :xmlns                => 'urn:iso:std:iso:20022:tech:xsd:pain.008.002.02',
                     :'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
                     :'xsi:schemaLocation' => 'urn:iso:std:iso:20022:tech:xsd:pain.008.002.02 pain.008.002.02.xsd' do
      builder.CstmrDrctDbtInitn do
        self.to_xml builder
      end
    end
  end
end
