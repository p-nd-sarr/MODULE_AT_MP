class Enrolement::AssureTpe < ActiveRecord::Base
  self.table_name = 'assure_tpe'
  establish_connection ENROLEMENT_BIO_DB
end
