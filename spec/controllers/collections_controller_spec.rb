# require 'rails_helper'
require 'spec_helper'

RSpec.describe CollectionsController, :type => :controller do

  describe 'GET Collection home page' do
    context 'with params[:letter]' do
      it "populates an array of collections " do

      end

      it "renders the :index template" do

      end

    end

    context 'without params' do
      it "populates an array of all collections" do

      end

      it "renders the :index template"
    end
  end

  describe "GET #show" do
    it "assigns the requested Collection object to @collection" do

    end

    it "renders the :show template" do

    end
  end

  describe "GET #new" do
    it "assigns a new Collection object to @collection "
    it "renders the :new template"
  end

  describe "GET #edit" do
    it "assigns the requested Collection object to @collection"
    it "renders the :edit template"
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "save the new collection in DB"
      it "redirects to collection#show"
    end

    context "with invalid attributes" do
      it "does not save the new collection in DB"
      it "re-renders the :new template"
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the collection in DB"
      it "redirects to the collection#show"
    end

    context "with invalid attributes" do
      it "does not update the collection"
      it "re-renders the :edit template"
    end
  end

  describe "DELETE #destroy" do
    context "with valid collection id" do
      it "deletes the collection from DB"
      it "redirects to collection home page"
    end

    context "with invalid collection id" do
      it "does not delete collection from DB"
      it "re-renders the :show template"
    end
  end


end
