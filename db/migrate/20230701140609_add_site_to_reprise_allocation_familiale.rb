class AddSiteToRepriseAllocationFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocations_familiales_migrees, :reprise_site, :integer
  end
end
