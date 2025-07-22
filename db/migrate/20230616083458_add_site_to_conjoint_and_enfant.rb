class AddSiteToConjointAndEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :reprise_site, :integer
    add_column :enfants, :reprise_site, :integer
  end
end
