# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :local_government_area do
    sequence(:name) { |n| "LGA #{n}" }
  end
end
