# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :land_and_property_information_record do
    sequence(:cadastre_id)
    lot_number "123"
    section_number "456"
    plan_label "DP789"
    title_reference "123/456/DP789"
    lga_name "BOGAN SHIRE"
    start_date "30-JUN-1971 12:34:56"
    end_date "30-JUN-1971 12:34:56"
    modified_date "30-JUN-1971 12:34:56"
    last_update "30-JUN-1971 12:34:56"
    md5sum 'abcdef0123456789'
  end
end
