class CreateLocalGovernmentAreasUsers < ActiveRecord::Migration
  def change
    create_table :local_government_areas_users, :id => false do |t|
      t.references :local_government_area
      t.references :user
    end
    add_index :local_government_areas_users, [
      :local_government_area_id, :user_id
    ], :name => 'index_lgas_users'
  end
end
