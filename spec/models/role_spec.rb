require 'spec_helper'

describe Role do

  it "has a valid factory" do
    expect(FactoryGirl.create(:role)).to be_valid
    expect(FactoryGirl.create(:role_admin)).to be_valid
    expect(FactoryGirl.create(:role_data_owner)).to be_valid
    expect(FactoryGirl.create(:role_researcher)).to be_valid
  end

  describe "Associations" do
    it { should have_many(:users) }
  end
  
  describe "Scopes" do
    describe "By name" do
      it "should order the roles by name and include all roles" do
        r1 = Role.create(:name => "bcd")
        r2 = Role.create(:name => "aaa")
        r3 = Role.create(:name => "abc")
        Role.by_name.should eq([r2, r3, r1])
      end
    end
  end
    
  describe "Validations" do
    it { should validate_presence_of(:name) }

    it "should reject duplicate names" do
      attr = {:name => "abc"}
      Role.create!(attr)
      with_duplicate_name = Role.new(attr)
      with_duplicate_name.should_not be_valid
    end

    it "should reject duplicate names identical except for case" do
      Role.create!(:name => "ABC")
      with_duplicate_name = Role.new(:name => "abc")
      with_duplicate_name.should_not be_valid
    end
  end

end

describe Role, 'validation' do
  it {should validate_presence_of(:name)}
  it {should validate_uniqueness_of(:name)}
end

describe Role, 'Association' do
  it {should have_many(:users)}
end