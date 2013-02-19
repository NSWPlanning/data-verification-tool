# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :local_government_area_record do

    date_of_update DateTime.now

    council_id "100001"
    sequence(:dp_lot_number) { |n| n }
    dp_plan_number "DP123456"
    ad_st_name "Broughton"
    ad_postcode "2570"
    ad_suburb "CAMDEN"
    ad_lga_name "Camden Council"
    lep_si_zone "B4"
    md5sum "md5432109876543210987654321095dm"

    association :land_and_property_information_record,
      :factory => :land_and_property_information_record

    association :local_government_area,
      :factory => :local_government_area
  end
end
