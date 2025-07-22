class Enrolement::Assure < ActiveRecord::Base
  self.table_name = 'assure'
  establish_connection ENROLEMENT_BIO_DB
end
