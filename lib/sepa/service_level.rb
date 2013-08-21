# encoding: utf-8
require 'sepa/base'

# Vereinbarung oder Regel, nach der die Transaktion verarbeitet werden sollte
class SEPA::ServiceLevel < SEPA::Base
  # Code einer vorvereinbarten Serviceleistung zwischen den Parteien
  attribute :code, 'Cd'
end
