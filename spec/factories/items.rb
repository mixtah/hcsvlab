# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :item do
    association :collection
    primary_text_path "so far i don't know what's this"
    annotation_path "you know what's this?"
    json_metadata '{"purpose" : "unknown"}'
    sequence(:handle) {|n| "#{collection.name}:kid_#{n}"}
    uri {"http://localhost:3000/catalog/#{handle.split(':').first}/#{handle.split(':').last}"}
  end

end
