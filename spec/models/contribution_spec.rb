require 'spec_helper'

describe Contribution do
  # pending "add some examples to (or delete) #{__FILE__}"

  it "has a valid factory" do
    expect(FactoryGirl.build(:contribution)).to be_valid
  end

  it "has correct associated collection" do
    contrib = FactoryGirl.create(:contribution)
    coll = Collection.find_by_id(contrib.collection_id)
    expect(contrib.name).to eq("#{coll.name}-contrib")
  end
end
