class AddRegimeToAdminBareme < ActiveRecord::Migration[5.2]
  def self.up
    add_column :admin_baremes, :regime, :integer

    Admin::Bareme.all.each { |bareme|
      bareme.save
    }
  end

  def self.down
    remove_column :admin_baremes, :regime
  end
end
