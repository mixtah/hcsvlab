# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_licence_request, :class => 'UserLicenceRequest' do
    request_type "collection"
  end
end
