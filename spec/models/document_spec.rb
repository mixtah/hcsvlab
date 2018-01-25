require 'spec_helper'

describe Document do
  # before(:each) do
  #   Document.delete_all
  # end
  # after(:each) do
  #   Document.delete_all
  # end

  it "has a valid factory" do
    expect(FactoryGirl.build(:document)).to be_valid
  end

  it "has correct associated item" do
    doc = FactoryGirl.create(:document)
    item = Item.find_by_id(doc.item_id)
    expect(doc.file_path).to eq("/data/collections/#{item.handle.split(':').first}/#{doc.file_name}")
  end

  it "has valid multiple documents" do
    item = FactoryGirl.create(:item)
    doc1 = FactoryGirl.create(:document, item: item, file_name: "Rodney.wav")
    doc2 = FactoryGirl.create(:document, item: item, file_name: "Isaac.wav")
    doc3 = FactoryGirl.create(:document, item: item, file_name: "Phoebe.wav")

    expect(doc3).to be_valid
  end

end

describe Document, 'validation' do
  it {should validate_presence_of(:file_name)}

  it {should validate_presence_of(:file_path)}

  it {should validate_presence_of(:item_id)}
end

describe Document, 'association' do
  it {should have_many(:document_audits)}

  it {should belong_to(:item)}
end