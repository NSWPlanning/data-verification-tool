# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :non_standard_instrumentation_zone do
    name "MyText"
    local_government_area nil
    local_government_area_record_council_id 1
  end
end
