# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :document do
    association :item
    sequence(:file_name) {|n| "phoebe_#{n}.wav"}
    file_path {"/data/collections/#{item.handle.split(':').first}/#{file_name}"}
    doc_type {"#{file_name.split('.').last}"}
    mime_type "Audio"
  end
end