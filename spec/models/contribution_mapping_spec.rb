require 'spec_helper'

describe ContributionMapping do

  it "has a valid factory" do
    expect(FactoryGirl.create(:contribution_mapping)).to be_valid
  end

  it "has correct associated contribution, item and document" do
    cm = FactoryGirl.create(:contribution_mapping)
    contrib = cm.contribution
    item = cm.item
    document = cm.document

    expect(contrib.collection.id).to eq(item.collection.id)
    expect(document.item.id).to eq(item.id)
  end

end
