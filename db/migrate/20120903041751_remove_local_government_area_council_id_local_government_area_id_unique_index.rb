class RemoveLocalGovernmentAreaCouncilIdLocalGovernmentAreaIdUniqueIndex < ActiveRecord::Migration
  def up
    remove_index :local_government_area_records,
      :name =>  'index_council_id_lga_id'
  end

  def down
    add_index :local_government_area_records,
      [:council_id, :local_government_area_id],
      :name => 'index_council_id_lga_id', :unique => true
  end
end
