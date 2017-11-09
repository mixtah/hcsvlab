# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contribution do
    name {"#{collection.name}-contrib"}
    association :collection
    owner { collection.owner }
    description {"Long long ago there was a description in [#{name}]...the end."}
  end
end
