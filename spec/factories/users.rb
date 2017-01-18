FactoryGirl.define do
  factory :user do |f|
    f.first_name "Fred"
    f.last_name "Bloggs"
    f.password "Pas$w0rd"
    f.sequence(:email) { |n| "#{n}@intersect.org.au" }

    factory :admin do

    end

    factory :data_owner do

    end
  end
end
