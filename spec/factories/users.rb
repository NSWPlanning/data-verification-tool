FactoryGirl.define do

  factory :user do
    sequence(:name)   {|n| "User #{n}"}
    sequence(:email)  {|n| "user_#{n}@example.com"}
    password 'password'

    trait :admin do
      roles [:admin]
    end

    factory :admin_user, :traits => [:admin]
  end

end
