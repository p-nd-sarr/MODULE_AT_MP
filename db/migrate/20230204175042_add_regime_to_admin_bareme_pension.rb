class AddRegimeToAdminBaremePension < ActiveRecord::Migration[5.2]
  def self.up
    add_column :admin_bareme_pensions, :regime, :integer

    Admin::BaremePension.all.each { |bareme|
      bareme.save
    }
  end

  def self.down
    remove_column :admin_bareme_pensions, :regime
  end
end
