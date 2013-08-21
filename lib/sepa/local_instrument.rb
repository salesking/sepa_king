# encoding: utf-8
require 'sepa/base'

# Lastschriftart
class SEPA::LocalInstrument < SEPA::Base
  # In kodierter Form
  attribute :code, 'Cd'
end
