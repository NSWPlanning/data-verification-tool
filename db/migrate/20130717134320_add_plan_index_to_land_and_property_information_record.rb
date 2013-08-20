class AddPlanIndexToLandAndPropertyInformationRecord < ActiveRecord::Migration
  def change
    add_index :land_and_property_information_records, :plan_label, { name: 'plan_label' }
      # default index name is too long; override the name.    
  end
end
