# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collection_attachment, :class => 'CollectionAttachments' do
    file_name "MyString"
    stringcontent_type "MyString"
    stringfile_size "MyString"
    integer "MyString"
  end
end
