class AddAliasToLocalGovernmentArea < ActiveRecord::Migration
  def change
    add_column :local_government_areas, :alias, :string, :unique => true
  end
end
