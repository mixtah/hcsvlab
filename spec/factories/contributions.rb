# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contribution do
    name "MyString"
    user nil
    collection nil
    description "MyText"
  end
end
