require 'spec_helper'

describe Item do

  it "has a valid factory" do
    expect(FactoryGirl.create(:item)).to be_valid
  end

  it "has correct associated collection" do
    item = FactoryGirl.create(:item)
    coll = Collection.find_by_id(item.collection_id)
    expect(item.handle.split(":").first).to eq(coll.name)
  end

end

describe Item, 'validation' do
  it {should validate_uniqueness_of(:handle)}
  it {should validate_presence_of(:handle)}

  it {should validate_presence_of(:uri)}

  it {should validate_presence_of(:collection_id)}
end

describe Item, 'association' do
  it {should have_many(:documents)}

  it {should belong_to(:collection)}
end