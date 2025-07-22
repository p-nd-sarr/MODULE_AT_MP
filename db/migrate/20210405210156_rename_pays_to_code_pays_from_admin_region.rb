class RenamePaysToCodePaysFromAdminRegion < ActiveRecord::Migration[5.2]
  def self.up
    rename_column :admin_regions, :pays, :code_pays

    Admin::Region.where(code_pays: 'Sénégal').update_all(code_pays: 'SEN')
  end

  def self.down
    rename_column :admin_regions, :code_pays, :pays

    Admin::Region.where(code_pays: 'SEN').update_all(code_pays: 'Sénégal')
  end
end
