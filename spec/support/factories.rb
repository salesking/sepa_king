# encoding: utf-8

def credit_transfer_transaction
  { name:                   'Telekomiker AG',
    bic:                    'PBNKDEFF370',
    iban:                   'DE37112589611964645802',
    amount:                 102.50,
    reference:              'XYZ-1234/123',
    remittance_information: 'Rechnung vom 22.08.2013'
  }
end

def direct_debt_transaction
  { name:                      'Müller & Schmidt oHG',
    bic:                       'GENODEF1JEV',
    iban:                      'DE68210501700012345678',
    amount:                    750.00,
    reference:                 'XYZ/2013-08-ABO/6789',
    remittance_information:    'Vielen Dank für Ihren Einkauf!',
    mandate_id:                'K-08-2010-42123',
    mandate_date_of_signature: Date.new(2010,7,25)
  }
end
