require 'rails_helper'

describe CollectionProperty do
  # pending "add some examples to (or delete) #{__FILE__}"

  it "is valid with property and value" do
    expect(build(:collection_property)).to be_valid
  end

  it "is invalid without a property" do
    p = build(:collection_property, property: nil)
    p.valid?
    expect(p.errors[:property]).to include("can't be blank")
  end

  it "is invalid without a value" do
    p = build(:collection_property, value: nil)
    p.valid?
    expect(p.errors[:value]).to include("can't be blank")
  end
end
