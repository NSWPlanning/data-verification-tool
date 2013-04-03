# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :non_standard_instrumentation_zone do
    local_government_area nil

    # CSV
    date_of_update DateTime.now
    council_id "10001"
    lep_nsi_zone "R2"
    lep_si_zone "D2"
    lep_name "Mapping for one zone to another"

    md5sum "abcdefghijklmniopqrstuvwxyz123"
  end
end
