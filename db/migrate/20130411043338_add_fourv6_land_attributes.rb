class AddFourv6LandAttributes < ActiveRecord::Migration
  def change
    add_column :local_government_area_records, :Ex_exempt_schedule_4,    :string, :null => true
    add_column :local_government_area_records, :Ex_complying_schedule_5, :string, :null => true
    add_column :local_government_area_records, :Ex_contaminated_land,    :string, :null => true
    add_column :local_government_area_records, :If_SEPP_rural_lands,     :string, :null => true
  end
end
