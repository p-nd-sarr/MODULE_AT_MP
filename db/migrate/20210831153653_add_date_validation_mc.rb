class AddDateValidationMc < ActiveRecord::Migration[5.2]
  def change
    add_column :at_rechutes, :date_validation_mc, :date
    add_column :at_rechutes, :date_validation_rechute, :date
    add_column :at_rechutes, :date_rejet_rechute, :date
    add_column :at_rechutes, :description_avis, :string
    add_column :at_rechutes, :avis, :string

    

  end
end
