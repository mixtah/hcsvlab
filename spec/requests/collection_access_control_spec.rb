require 'spec_helper'

RSpec.describe CollectionsController, :type => :request do
  describe "Test collection access control" do

    let(:user_admin) {FactoryGirl.create(:user_admin)}
    let(:user_owner) {FactoryGirl.create(:user_data_owner)}
    let(:user_researcher) {FactoryGirl.create(:user_researcher)}
    let!(:draft_collection) {FactoryGirl.create(:collection, owner: user_owner, name: "draft_collection")}
    let!(:released_collection) {FactoryGirl.create(:collection, status: "RELEASED", owner: user_owner, name: "my_released_collection")}
    let!(:finalised_collection) {FactoryGirl.create(:collection, status: "FINALISED", owner: user_owner, name: "my_finalised_collection")}
    let!(:private_released_collection) {FactoryGirl.create(:collection, status: "RELEASED", private: true, owner: user_owner, name: "my_private_released_collection")}
    let!(:private_finalised_collection) {FactoryGirl.create(:collection, status: "FINALISED", private: true, owner: user_owner, name: "my_private_finalised_collection")}

    describe "visible to collection list" do
      context "collection with status DRAFT" do
        it "can't be visible to guest" do
          # get collection_index_path, nil, {'HTTP_ACCEPT' => "application/json"}
          get collection_index_path
          expect(response.status).to eq(200)
          expect(response.body).not_to match /draft_collection/
        end

        it "can be visible to admin" do
          request_sign_in user_admin
          get collection_index_path
          expect(response.status).to eq(200)
          expect(response.body).to match /draft_collection/
        end

        it "can be visible to user(owner)" do
          request_sign_in user_owner
          get collection_index_path
          expect(response.status).to eq(200)
          expect(response.body).to match /draft_collection/
        end

        it "can't be visible to user(non-owner)" do
          request_sign_in user_researcher
          get collection_index_path
          expect(response.status).to eq(200)
          expect(response.body).not_to match /draft_collection/
        end
      end

      context "collection with status RELEASED" do
        it "can be visible to guest" do
          get collection_index_path
          expect(response.status).to eq(200)
          expect(response.body).to match /my_released_collection/
        end

        it "can be visible to admin" do
          request_sign_in user_admin
          get collection_index_path
          expect(response.status).to eq(200)
          expect(response.body).to match /my_released_collection/
        end

        it "can be visible to user(owner)" do
          request_sign_in user_owner
          get collection_index_path
          expect(response.status).to eq(200)
          expect(response.body).to match /my_released_collection/
        end

        it "can be visible to user(non-owner)" do
          request_sign_in user_researcher
          get collection_index_path
          expect(response.status).to eq(200)
          expect(response.body).to match /my_released_collection/
        end
      end

      context "collection with status FINALISED" do
        it "can be visible to guest" do
          get collection_index_path
          expect(response.status).to eq(200)
          expect(response.body).to match /my_finalised_collection/
        end

        it "can be visible to admin" do
          request_sign_in user_admin
          get collection_index_path
          expect(response.status).to eq(200)
          expect(response.body).to match /my_finalised_collection/
        end

        it "can be visible to user(owner)" do
          request_sign_in user_owner
          get collection_index_path
          expect(response.status).to eq(200)
          expect(response.body).to match /my_finalised_collection/
        end

        it "can be visible to user(non-owner)" do
          request_sign_in user_researcher
          get collection_index_path
          expect(response.status).to eq(200)
          expect(response.body).to match /my_finalised_collection/
        end
      end
    end

    describe "visible to collection detail" do
      context "collection with status DRAFT" do
        it "can't be accessible to guest" do
          get collection_path(draft_collection.name)
          expect(response.status).to eq(302)
        end

        it "can be visible to admin" do
          request_sign_in user_admin
          get collection_path(draft_collection.name)
          expect(response.status).to eq(200)
          expect(response.body).to match /draft_collection/
        end

        it "can be visible to user(owner)" do
          request_sign_in user_owner
          get collection_path(draft_collection.name)
          expect(response.status).to eq(200)
          expect(response.body).to match /draft_collection/
        end

        it "can't be visible to user(non-owner)" do
          request_sign_in user_researcher
          get collection_path(draft_collection.name)
          expect(response.status).to eq(302)
        end

        it "can be visible to user(non-owner) with owner's permission" do
          FactoryGirl.create(
            :user_licence_request,
            request_id: draft_collection.id,
            request_type: 'draft_collection_read',
            approved: true,
            user_id: user_researcher.id,
            owner_id: user_owner.id)
          request_sign_in user_researcher
          get collection_path(draft_collection.name)
          expect(response.status).to eq(200)
        end

      end

      context "collection with status RELEASED" do
        it "can be accessible to guest" do
          get collection_path(released_collection.name)
          expect(response.status).to eq(200)
          expect(response.body).to match /released_collection/
        end

        it "can't be accessible to guest while set private" do
          released_collection.set_privacy(true)
          get collection_path(released_collection.name)
          expect(response.status).to eq(302)
        end

        it "can be visible to admin" do
          request_sign_in user_admin
          get collection_path(released_collection.name)
          expect(response.status).to eq(200)
          expect(response.body).to match /released_collection/
        end

        it "can be visible to user(owner)" do
          request_sign_in user_owner
          get collection_path(released_collection.name)
          expect(response.status).to eq(200)
          expect(response.body).to match /released_collection/
        end

        it "can be visible to user(non-owner)" do
          request_sign_in user_researcher
          get collection_path(released_collection.name)
          expect(response.status).to eq(200)
          expect(response.body).to match /released_collection/
        end

        it "can't be visible to user(non-owner) while collection is private and user is not approved" do
          released_collection.set_privacy(true)
          request_sign_in user_researcher
          get collection_path(released_collection.name)
          expect(response.status).to eq(302)
        end

        it "can be visible to user(non-owner) while collection is private and user is approved" do
          released_collection.set_privacy(true)
          FactoryGirl.create(
            :user_licence_request,
            request_id: released_collection.id,
            approved: true,
            user_id: user_researcher.id,
            owner_id: user_owner.id)

          request_sign_in user_researcher
          get collection_path(released_collection.name)
          expect(response.status).to eq(200)
        end
      end

      context "collection with status FINALISED" do
        it "can't be accessible to guest while set private" do
          finalised_collection.set_privacy(true)
          get collection_path(finalised_collection.name)
          expect(response.status).to eq(302)
        end

        it "can be accessible to guest" do
          get collection_path(finalised_collection.name)
          expect(response.status).to eq(200)
          expect(response.body).to match /finalised_collection/
        end

        it "can be visible to admin" do
          request_sign_in user_admin
          get collection_path(finalised_collection.name)
          expect(response.status).to eq(200)
          expect(response.body).to match /finalised_collection/
        end

        it "can be visible to user(owner)" do
          request_sign_in user_owner
          get collection_path(finalised_collection.name)
          expect(response.status).to eq(200)
          expect(response.body).to match /finalised_collection/
        end

        it "can be visible to user(non-owner)" do
          request_sign_in user_researcher
          get collection_path(finalised_collection.name)
          expect(response.status).to eq(200)
          expect(response.body).to match /finalised_collection/
        end

        it "can be visible to user(non-owner) while collection is private and user is approved" do
          finalised_collection.set_privacy(true)
          FactoryGirl.create(
            :user_licence_request,
            request_id: finalised_collection.id,
            approved: true,
            user_id: user_researcher.id,
            owner_id: user_owner.id)

          request_sign_in user_researcher
          get collection_path(finalised_collection.name)
          expect(response.status).to eq(200)
        end

        it "can't be visible to user(non-owner) while collection is private and user is not approved" do
          finalised_collection.set_privacy(true)
          FactoryGirl.create(
            :user_licence_request,
            request_id: finalised_collection.id,
            approved: false,
            user_id: user_researcher.id,
            owner_id: user_owner.id)

          request_sign_in user_researcher
          get collection_path(finalised_collection.name)
          expect(response.status).to eq(302)
        end
      end
    end

    describe "visible to collection edit" do
      context "collection with status DRAFT" do
        it "can't be accessible to guest" do
          get edit_collection_path(draft_collection.name)
          expect(response.status).to eq(302)
        end

        it "can be visible to admin" do
          request_sign_in user_admin
          get edit_collection_path(draft_collection.name)
          expect(response.status).to eq(200)
          expect(response.body).to match /draft_collection/
        end

        it "can be visible to user(owner)" do
          request_sign_in user_owner
          get edit_collection_path(draft_collection.name)
          expect(response.status).to eq(200)
          expect(response.body).to match /draft_collection/
        end

        it "can't be visible to user(non-owner)" do
          request_sign_in user_researcher
          get edit_collection_path(draft_collection.name)
          expect(response.status).to eq(302)
        end
      end

      context "collection with status RELEASED" do
        it "can't be accessible to guest" do
          get edit_collection_path(released_collection.name)
          expect(response.status).to eq(302)
        end

        it "can be visible to admin" do
          request_sign_in user_admin
          get edit_collection_path(released_collection.name)
          expect(response.status).to eq(200)
          expect(response.body).to match /released_collection/
        end

        it "can be visible to user(owner)" do
          request_sign_in user_owner
          get edit_collection_path(released_collection.name)
          expect(response.status).to eq(200)
          expect(response.body).to match /released_collection/
        end

        it "can't be visible to user(non-owner)" do
          request_sign_in user_researcher
          get edit_collection_path(released_collection.name)
          expect(response.status).to eq(302)
        end

      end

      context "collection with status FINALISED" do
        it "can't be accessible to guest" do
          get edit_collection_path(finalised_collection.name)
          expect(response.status).to eq(302)
        end

        it "can be visible to admin" do
          request_sign_in user_admin
          get edit_collection_path(finalised_collection.name)
          expect(response.status).to eq(200)
          expect(response.body).to match /finalised_collection/
        end

        it "can't be visible to user(owner)" do
          request_sign_in user_owner
          get edit_collection_path(finalised_collection.name)
          expect(response.status).to eq(302)
        end

        it "can't be visible to user(non-owner)" do
          request_sign_in user_researcher
          get edit_collection_path(finalised_collection.name)
          expect(response.status).to eq(302)
        end
      end
    end

  end

end


