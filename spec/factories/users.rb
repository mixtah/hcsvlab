FactoryGirl.define do
  factory :user do |f|
    f.first_name "Fred"
    f.last_name "Bloggs"
    f.password "Pas$w0rd"
    f.sequence(:email) { |n| "#{n}@alveo.edu.au" }

    factory :user_admin do |a|
      a.association :role, factory: :role_admin
      a.status "A"
    end

    factory :user_researcher do |r|
      r.association :role, factory: :role_researcher
      r.status "A"
    end

    factory :user_data_owner do |d|
      d.association :role, factory: :role_data_owner
      d.status "A"
    end

  end

end
