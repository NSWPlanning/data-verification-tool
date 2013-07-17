class AddPlanSectionLotIndexToLocalGovernmentAreaRecord < ActiveRecord::Migration
  def change
    add_index :local_government_area_records, [:dp_plan_number, :dp_section_number, :dp_lot_number], { name: 'title_reference' }
      # default index name is too long; override the name.
  end
end
