require 'rails_helper'

RSpec.describe CollectionsController, :type => :controller do
  before :each do
    @collection = create(:collection)
  end

  # shared_examples 'public access to controllers' do
  describe 'GET collection home page', :focus => true do
    context 'with params[:name]' do
      it "populates a specific collection" do
        get :index, name: @collection.name
        expect(assigns(:collection)).to match_array([@collection])
      end

      it "renders the :index template" do
        # = render :file => '/collections/show'
        get :index, name: @collection.name
        expect(response).to render_template :show

      end

    end

    context 'without params' do
      it "populates an array of all collections" do

      end

      it "renders the :index template" do

      end
    end
  end

  describe "GET #show" do
    it "assigns the requested Collection object to @collection" do

    end

    it "renders the :show template" do

    end
  end
  # end


  describe 'admin access' do

  end

  describe 'researcher access' do

  end

  describe 'data owner access' do

  end


  # describe "GET #new" do
  #   it "assigns a new Collection object to @collection "
  #   it "renders the :new template"
  # end
  #
  # describe "GET #edit" do
  #   it "assigns the requested Collection object to @collection"
  #   it "renders the :edit template"
  # end
  #
  # describe "POST #create" do
  #   context "with valid attributes" do
  #     it "save the new collection in DB"
  #     it "redirects to collection#show"
  #   end
  #
  #   context "with invalid attributes" do
  #     it "does not save the new collection in DB"
  #     it "re-renders the :new template"
  #   end
  # end
  #
  # describe "PATCH #update" do
  #   context "with valid attributes" do
  #     it "updates the collection in DB"
  #     it "redirects to the collection#show"
  #   end
  #
  #   context "with invalid attributes" do
  #     it "does not update the collection"
  #     it "re-renders the :edit template"
  #   end
  # end
  #
  # describe "DELETE #destroy" do
  #   context "with valid collection id" do
  #     it "deletes the collection from DB"
  #     it "redirects to collection home page"
  #   end
  #
  #   context "with invalid collection id" do
  #     it "does not delete collection from DB"
  #     it "re-renders the :show template"
  #   end
  # end

end
