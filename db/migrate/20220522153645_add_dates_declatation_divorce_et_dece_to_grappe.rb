class AddDatesDeclatationDivorceEtDeceToGrappe < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :date_declaration_divorce, :date
    add_column :conjoints, :date_declaration_deces, :date

    add_column :enfants, :date_declaration_deces, :date
  end
end
