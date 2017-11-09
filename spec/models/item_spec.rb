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