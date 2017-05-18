FactoryGirl.define do
  factory :role do |f|
    f.sequence(:name) { |n| "role-#{n}" }

    factory :role_admin do |u|
      u.name Role::SUPERUSER_ROLE
    end

    factory :role_data_owner do |u|
      u.name Role::DATA_OWNER_ROLE
    end

    factory :role_researcher do |u|
      u.name Role::RESEARCHER_ROLE
    end
  end
end
