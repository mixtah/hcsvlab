# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contribution_mapping do
    contribution {FactoryGirl.build(:contribution, :collection => item.collection)}
    item {document.item}
    association :document
  end
end
