class AddAliasesToLocalGovernmentArea < ActiveRecord::Migration
  def change
    rename_column :local_government_areas, :alias, :lpi_alias
    add_column :local_government_areas, :lga_alias, :string, :unique => true
    add_column :local_government_areas, :filename_alias, :string
  end
end
