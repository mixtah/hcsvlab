require 'spec_helper'

describe User do
  describe "Associations" do
    it { should belong_to(:role) }
  end

  describe "Initialization" do
    it 'should have initialized status as "U"', :focus => true do
      user = User.new
      expect(user.status).to eq "U"
    end
  end

  describe "Named Scopes" do
    describe "Users Pending Approval Scope" do
      it "should return users that are unapproved ordered by email address" do
        u1 = FactoryGirl.create(:user, :status => 'U', :email => "fasdf1@alveo.edu.au")
        u2 = FactoryGirl.create(:user, :status => 'A')
        u3 = FactoryGirl.create(:user, :status => 'U', :email => "asdf1@alveo.edu.au")
        u2 = FactoryGirl.create(:user, :status => 'R')
        User.pending_approval.should eq([u3,u1])
      end
    end
    describe "Approved Users Scope" do
      it "should return users that are approved ordered by email address" do
        u1 = FactoryGirl.create(:user, :status => 'A', :email => "fasdf1@alveo.edu.au")
        u2 = FactoryGirl.create(:user, :status => 'U')
        u3 = FactoryGirl.create(:user, :status => 'A', :email => "asdf1@alveo.edu.au")
        u4 = FactoryGirl.create(:user, :status => 'R')
        u5 = FactoryGirl.create(:user, :status => 'D')
        User.approved.should eq([u3,u1])
      end
    end
    describe "Deactivated or Approved Users Scope" do
      it "should return users that are approved ordered by email address" do
        u1 = FactoryGirl.create(:user, :status => 'A', :email => "fasdf1@alveo.edu.au")
        u2 = FactoryGirl.create(:user, :status => 'U')
        u3 = FactoryGirl.create(:user, :status => 'A', :email => "asdf1@alveo.edu.au")
        u4 = FactoryGirl.create(:user, :status => 'R')
        u5 = FactoryGirl.create(:user, :status => 'D', :email => "zz@inter.org")
        User.deactivated_or_approved.should eq([u3,u1, u5])
      end
    end
    describe "Approved admins Scope" do
      it "should return users with admin role that are approved ordered by email address" do
        super_role = FactoryGirl.create(:role, :name => Role::SUPERUSER_ROLE)
        other_role = FactoryGirl.create(:role, :name => Role::RESEARCHER_ROLE)
        u1 = FactoryGirl.create(:user, :status => 'A', :role => super_role, :email => "fasdf1@alveo.edu.au")
        u2 = FactoryGirl.create(:user, :status => 'A', :role => other_role)
        u3 = FactoryGirl.create(:user, :status => 'U', :role => super_role)
        u4 = FactoryGirl.create(:user, :status => 'R', :role => super_role)
        u5 = FactoryGirl.create(:user, :status => 'D', :role => super_role)
        User.approved_superusers.should eq([u1])
      end
    end
    describe "Approved researchers Scope" do
      it "should return users with researcher role that are approved ordered by email address" do
        super_role = FactoryGirl.create(:role, :name => Role::SUPERUSER_ROLE)
        researcher_role = FactoryGirl.create(:role, :name => Role::RESEARCHER_ROLE)
        u1 = FactoryGirl.create(:user, :status => 'A', :role => researcher_role, :email => "fasdf1@alveo.edu.au")
        u2 = FactoryGirl.create(:user, :status => 'A', :role => super_role)
        u3 = FactoryGirl.create(:user, :status => 'U', :role => researcher_role)
        u4 = FactoryGirl.create(:user, :status => 'R', :role => researcher_role)
        u5 = FactoryGirl.create(:user, :status => 'D', :role => researcher_role)
        User.approved_researchers.should eq([u1])
      end
    end
  end

  describe "Approve Access Request" do
    it "should set the status flag to A" do
      user = FactoryGirl.create(:user, :status => 'U')
      user.approve_access_request
      user.status.should eq("A")
    end
  end

  describe "Reject Access Request" do
    it "should set the status flag to R" do
      user = FactoryGirl.create(:user, :status => 'U')
      user.reject_access_request
      user.status.should eq("R")
    end
  end

  describe "Status Methods" do
    context "Active" do
      it "should be active" do
        user = FactoryGirl.create(:user, :status => 'A')
        user.approved?.should be_true
      end
      it "should not be pending approval" do
        user = FactoryGirl.create(:user, :status => 'A')
        user.pending_approval?.should be_false
      end
    end

    context "Unapproved" do
      it "should not be active" do
        user = FactoryGirl.create(:user, :status => 'U')
        user.approved?.should be_false
      end
      it "should be pending approval" do
        user = FactoryGirl.create(:user, :status => 'U')
        user.pending_approval?.should be_true
      end
    end

    context "Rejected" do
      it "should not be active" do
        user = FactoryGirl.create(:user, :status => 'R')
        user.approved?.should be_false
      end
      it "should not be pending approval" do
        user = FactoryGirl.create(:user, :status => 'R')
        user.pending_approval?.should be_false
      end
    end
  end

  describe "Update password" do
    it "should fail if current password is incorrect" do
      user = FactoryGirl.create(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "asdf", :password => "Pass.456", :password_confirmation => "Pass.456"})
      result.should be_false
      user.errors[:current_password].should eq ["is invalid"]
    end
    it "should fail if current password is blank" do
      user = FactoryGirl.create(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "", :password => "Pass.456", :password_confirmation => "Pass.456"})
      result.should be_false
      user.errors[:current_password].should eq ["can't be blank"]
    end
    it "should fail if new password and confirmation blank" do
      user = FactoryGirl.create(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "", :password_confirmation => ""})
      result.should be_false
      user.errors[:password].should eq ["can't be blank", "must be between 6 and 20 characters long and contain at least one uppercase letter, one lowercase letter, one digit and one symbol"]
    end
    it "should fail if confirmation blank" do
      user = FactoryGirl.create(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "Pass.456", :password_confirmation => ""})
      result.should be_false
      user.errors[:password].should eq ["doesn't match confirmation"]
    end
    it "should fail if confirmation doesn't match new password" do
      user = FactoryGirl.create(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "Pass.456", :password_confirmation => "Pass.678"})
      result.should be_false
      user.errors[:password].should eq ["doesn't match confirmation"]
    end
    it "should fail if password doesn't meet rules" do
      user = FactoryGirl.create(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "Pass4567", :password_confirmation => "Pass4567"})
      result.should be_false
      user.errors[:password].should eq ["must be between 6 and 20 characters long and contain at least one uppercase letter, one lowercase letter, one digit and one symbol"]
    end
    it "should succeed if current password correct and new password ok" do
      user = FactoryGirl.create(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "Pass.456", :password_confirmation => "Pass.456"})
      result.should be_true
    end
    it "should always blank out passwords" do
      user = FactoryGirl.create(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "Pass.456", :password_confirmation => "Pass.456"})
      user.password.should be_blank
      user.password_confirmation.should be_blank
    end
  end

  describe "Find the number of superusers method" do
    it "should return true if there are at least 2 superusers" do
      super_role = FactoryGirl.create(:role, :name => Role::SUPERUSER_ROLE)
      user_1 = FactoryGirl.create(:user, :role => super_role, :status => 'A', :email => 'user1@alveo.edu.au')
      user_2 = FactoryGirl.create(:user, :role => super_role, :status => 'A', :email => 'user2@alveo.edu.au')
      user_3 = FactoryGirl.create(:user, :role => super_role, :status => 'A', :email => 'user3@alveo.edu.au')
      user_1.check_number_of_superusers(1, 1).should eq(true)
    end

    it "should return false if there is only 1 superuser" do
      super_role = FactoryGirl.create(:role, :name => Role::SUPERUSER_ROLE)
      user_1 = FactoryGirl.create(:user, :role => super_role, :status => 'A', :email => 'user1@alveo.edu.au')
      user_1.check_number_of_superusers(1, 1).should eq(false)
    end
    
    it "should return true if the logged in user does not match the user record being modified" do  
      super_role = FactoryGirl.create(:role, :name => Role::SUPERUSER_ROLE)
      research_role = FactoryGirl.create(:role, :name => 'Researcher')
      user_1 = FactoryGirl.create(:user, :role => super_role, :status => 'A', :email => 'user1@alveo.edu.au')
      user_2 = FactoryGirl.create(:user, :role => research_role, :status => 'A', :email => 'user2@alveo.edu.au')
      user_1.check_number_of_superusers(1, 2).should eq(true)
    end
  end

  describe "Validations" do
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :email }
    it { should validate_presence_of :password }

    #password rules: at least one lowercase, uppercase, number, symbol
    # too short < 6
    it { should_not allow_value("AB$9a").for(:password) }
    # too long > 20
    it { should_not allow_value("Aa0$56789012345678901").for(:password) }
    # missing upper
    it { should_not allow_value("aaa000$$$").for(:password) }
    # missing lower
    it { should_not allow_value("AAA000$$$").for(:password) }
    # missing digit
    it { should_not allow_value("AAAaaa$$$").for(:password) }
    # missing symbol
    it { should_not allow_value("AAA000aaa").for(:password) }
    # ok
    it { should allow_value("AB$9aa").for(:password) }

    # check each of the possible symbols we allow
    it { should allow_value("AAAaaa000!").for(:password) }
    it { should allow_value("AAAaaa000@").for(:password) }
    it { should allow_value("AAAaaa000#").for(:password) }
    it { should allow_value("AAAaaa000$").for(:password) }
    it { should allow_value("AAAaaa000%").for(:password) }
    it { should allow_value("AAAaaa000^").for(:password) }
    it { should allow_value("AAAaaa000&").for(:password) }
    it { should allow_value("AAAaaa000*").for(:password) }
    it { should allow_value("AAAaaa000(").for(:password) }
    it { should allow_value("AAAaaa000)").for(:password) }
    it { should allow_value("AAAaaa000-").for(:password) }
    it { should allow_value("AAAaaa000_").for(:password) }
    it { should allow_value("AAAaaa000+").for(:password) }
    it { should allow_value("AAAaaa000=").for(:password) }
    it { should allow_value("AAAaaa000{").for(:password) }
    it { should allow_value("AAAaaa000}").for(:password) }
    it { should allow_value("AAAaaa000[").for(:password) }
    it { should allow_value("AAAaaa000]").for(:password) }
    it { should allow_value("AAAaaa000|").for(:password) }
    it { should allow_value("AAAaaa000\\").for(:password) }
    it { should allow_value("AAAaaa000;").for(:password) }
    it { should allow_value("AAAaaa000:").for(:password) }
    it { should allow_value("AAAaaa000'").for(:password) }
    it { should allow_value("AAAaaa000\"").for(:password) }
    it { should allow_value("AAAaaa000<").for(:password) }
    it { should allow_value("AAAaaa000>").for(:password) }
    it { should allow_value("AAAaaa000,").for(:password) }
    it { should allow_value("AAAaaa000.").for(:password) }
    it { should allow_value("AAAaaa000?").for(:password) }
    it { should allow_value("AAAaaa000/").for(:password) }
    it { should allow_value("AAAaaa000~").for(:password) }
    it { should allow_value("AAAaaa000`").for(:password) }
  end

  describe "Get superuser emails" do
    it "should find all approved superusers and extract their email address" do
      super_role = FactoryGirl.create(:role, :name => "admin")
      researcher_role = FactoryGirl.create(:role, :name => "researcher")
      super_1 = FactoryGirl.create(:user, :role => super_role, :status => "A", :email => "a@alveo.edu.au")
      super_2 = FactoryGirl.create(:user, :role => super_role, :status => "U", :email => "b@alveo.edu.au")
      super_3 = FactoryGirl.create(:user, :role => super_role, :status => "A", :email => "c@alveo.edu.au")
      super_4 = FactoryGirl.create(:user, :role => super_role, :status => "D", :email => "d@alveo.edu.au")
      super_5 = FactoryGirl.create(:user, :role => super_role, :status => "R", :email => "e@alveo.edu.au")
      researcher = FactoryGirl.create(:user, :role => researcher_role, :status => "A", :email => "f@alveo.edu.au")

      supers = User.get_superuser_emails
      supers.should eq(["a@alveo.edu.au", "c@alveo.edu.au"])
    end
  end

  describe "User Licence Agreement Acceptance" do
    before(:each) do
      CollectionList.delete_all
      Collection.delete_all
      Licence.delete_all
    end
    after(:each) do
      CollectionList.delete_all
      Collection.delete_all
      Licence.delete_all
    end

    it "Should add read group to the user" do
      user = FactoryGirl.create(:user, :status => 'A')
      collection  = FactoryGirl.create(:collection, :name=>"ace")
      licence = FactoryGirl.create(:licence)
      collection.licence = licence

      user.add_agreement_to_collection(collection, UserLicenceAgreement::READ_ACCESS_TYPE)

      user.groups.should eq(["ace-read"])
    end

    it "Should remove read group to the user" do
      user = FactoryGirl.create(:user, :status => 'A')
      collection  = FactoryGirl.create(:collection, :name=>"ace")
      licence = FactoryGirl.create(:licence)
      collection.licence = licence

      user.add_agreement_to_collection(collection, UserLicenceAgreement::READ_ACCESS_TYPE)

      user.groups.should eq(["ace-read"])

      user.remove_agreement_to_collection(collection, UserLicenceAgreement::READ_ACCESS_TYPE)
      user.reload

      user.groups.should be_empty
    end
  end
  
end
