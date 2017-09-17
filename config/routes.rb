HcsvlabWeb::Application.routes.draw do

  use_doorkeeper

  # This constraint specify that we are going to accept any character except '/' for an item id.
  catalogRoutesConstraints = {:itemId => /[^\/]+/}
  catalogRoutesConstraintsIncludingJson = {:itemId => /(?:(?!\.json|\/).)+/i}

  # root :to => "catalog#index"
  root :to => "collections#index"
  get "/", :to => 'collections#index', :as => 'collection_index'

  get "version", :to => "application#version"
  get "metrics", :to => 'application#metrics', :as => 'view_metrics'
  get "metrics/download", :to => 'application#metrics_download', :as => 'download_metrics'

  # get "/", :to => 'catalog#index', :as => 'catalog_index'
  get "catalogs", :to => 'catalog#index', :as => 'catalog_index'
  get "catalog/advanced_search", :to => 'catalog#advanced_search', :as => 'catalog_advanced_search'
  get "catalog/searchable_fields", :to => 'catalog#searchable_fields', :as => 'catalog_searchable_fields'
  get "catalog/search", :to => 'catalog#search', :as => 'catalog_search'
  get 'sparql/:collection', :to => 'catalog#sparqlQuery', :as => 'catalog_sparqlQuery'

  # :show and :update are for backwards-compatibility with catalog_url named routes
  get 'catalog/:collection/:itemId', :to => 'catalog#show', :as => "catalog", :constraints => catalogRoutesConstraintsIncludingJson

  # put 'catalog/:collection/:itemId', :to => 'catalog#update', :as => "catalog", :constraints => catalogRoutesConstraintsIncludingJson
  get 'catalog/:collection/:itemId', :to => 'catalog#show', :as => "solr_document", :constraints => catalogRoutesConstraintsIncludingJson
  # put 'catalog/:collection/:itemId', :to => 'catalog#update', :as => "solr_document", :constraints => catalogRoutesConstraintsIncludingJson

  get 'catalog/:collection/:itemId', :to => 'catalog#show', :as => "item"

  # for header navbar
  get "discover", :to => 'catalog#index', :as => 'header_discover'

  # Collection definitions
  get "catalog", :to => 'collections#index', :as => 'collections'
  get "collections", :to => 'collections#index', :as => 'collections'
  get "catalog/:id", :to => 'collections#show', :as => 'collection'
  post "catalog/:id", :to => 'collections#add_items_to_collection', :as => 'collection'
  # KL: edit collection
  get 'catalog-edit/:id/edit', :to => 'collections#edit_collection', :as => 'edit_collection'
  put 'catalog-update/:id', :to => 'collections#update_collection', :as => 'update_collection'
  delete 'catalog-delete/:id', :to => 'collections#delete_collection', :as => 'delete_collection'
  get 'catalog-create', :to => 'collections#web_create_collection', :as => 'web_create_collection'
  post 'catalog-create', :to => 'collections#web_create_collection'

  # collection attachment
  resources :collections do
    # without collection_id can't proceed, so must include that
    resources :attachments, only: [:index, :new, :create]
  end
  get 'collections/:collection_id/attachments', :to => 'attachments#index', :as => 'attachments'
  get 'collections/:collection_id/attachments/new', :to => 'attachments#new', :as => 'new_attachment'
  post 'collections/:collection_id/attachments', :to => 'attachments#create', :as => 'create_attachment'
  # can proceed with own attachment id
  resources :attachments, only: [:show, :edit, :update, :destroy]



  # put "catalog/:id", :to => 'collections#edit_collection', :as => 'collection'
  post "catalog", :to => 'collections#create', :as => 'collections'
  delete "catalog/:collectionId/:itemId", :to => 'collections#delete_item_from_collection', :as => 'delete_collection_item', :constraints => catalogRoutesConstraintsIncludingJson
  put "catalog/:collectionId/:itemId", :to => 'collections#update_item', :as => 'update_collection_item', :constraints => catalogRoutesConstraints
  post "catalog/:collectionId/:itemId", :to => 'collections#add_document_to_item', :as => 'add_item_document', :constraints => catalogRoutesConstraints
  delete "catalog/:collectionId/:itemId/document/:filename", :to => 'collections#delete_document_from_item', :as => 'delete_item_document', :filename => /.*/, :constraints => catalogRoutesConstraints

  get 'catalog/:collectionId/:itemId/delete', :to => 'collections#delete_item_via_web_app', :as => "delete_item_web", :constraints => catalogRoutesConstraintsIncludingJson

  get "catalog/:collectionId/:itemId/document/:filename/delete", :to => 'collections#delete_document_via_web_app', :as => 'delete_item_document_web', :filename => /.*/, :constraints => catalogRoutesConstraints

  # In /config/initializers/blacklight_routes.rb we are overriding one of the methods of this class
  Blacklight::Routes.new(self, :except => [:solr_document]).draw


  get "catalog/:collection/:itemId/primary_text", :to => 'catalog#primary_text', :as => 'catalog_primary_text', :constraints => catalogRoutesConstraints
  get "catalog/:collection/:itemId/document/:filename", :to => 'catalog#document', :as => 'catalog_document', :format => false, :filename => /.*/, :constraints => catalogRoutesConstraints
  get "catalog/:collection/:itemId/document/", :to => 'catalog#document', :as => 'catalog_document_api', :constraints => catalogRoutesConstraints
  get "catalog/:collection/:itemId/annotations", :to => 'catalog#annotations', :as => 'catalog_annotations', :constraints => catalogRoutesConstraints
  post 'catalog/:collection/:itemId/annotations', :to => 'catalog#upload_annotation', :constraints => catalogRoutesConstraints
  get "catalog/:collection/:itemId/annotations/properties", :to => 'catalog#annotation_properties', :as => 'catalog_annotation_properties', :constraints => catalogRoutesConstraints
  get "catalog/:collection/:itemId/annotations/types", :to => 'catalog#annotation_types', :as => 'catalog_annotation_types', :constraints => catalogRoutesConstraints

  post 'catalog/download_items', :to => 'catalog#download_items', :as => 'catalog_download_items_api'
  #get 'catalog/download_annotation/:id', :to => 'catalog#download_annotation', :as => 'catalog_download_annotation'


  get "add-item/:id", :to => 'collections#web_add_item', :as => 'web_add_item'
  post "add-item/:id", :to => 'collections#web_add_item'

  get "add-document/:collection/:itemId", :to => 'collections#web_add_document', :as => 'web_add_document'
  post "add-document/:collection/:itemId", :to => 'collections#web_add_document'

  # speaker metadata
  get "/speakers/:collection", :to => "speakers#index", :as => "speakers"
  post "/speakers/:collection", :to => "speakers#create", :as => "create_speaker"

  get "/speakers/:collection/:speaker_id", :to => "speakers#show", :as => "show_speaker"
  # rails 3.2 only supports PUT, rails 4 supports PATCH
  put "/speakers/:collection/:speaker_id", :to => "speakers#update", :as => "update_speaker"
  delete "/speakers/:collection/:speaker_id", :to => "speakers#delete", :as => "delete_speaker"


  HydraHead.add_routes(self)

  devise_for :users, controllers: {registrations: "user_registers", passwords: "user_passwords"}

  devise_scope :user do
    # KL: oauth2
    get "/users/sign_in", :to => "devise/sessions#oauth2_new", :as => 'oauth2_sign_in'

    get "/users/aaf_sign_in", :to => "devise/sessions#aaf_new"
    get "/account/", :to => "user_registers#index"
    get "/account/edit", :to => "user_registers#edit"
    get "/account/edit_password", :to => "user_registers#edit_password" #allow users to edit their own password
    put "/account/update_password", :to => "user_registers#update_password" #allow users to update their own password
    get "/account/generate_token", :to => "user_registers#generate_token" #allow users to generate an API token
    get "/account_api_key", :to => "user_registers#download_token"
    get "/account/get_details", :to => "user_registers#download_details"
    get "/account/licence_agreements", :to => "user_registers#licence_agreements"
    delete "/account/delete_token", :to => "user_registers#delete_token" #allow users to delete their API token
    delete "/account/licence_agreements/:id/cancel_request", :to => "user_licence_requests#cancel_request", :as => 'cancel_request'
  end

  resources :item_lists, :only => [:index, :show, :create, :update, :destroy] do
    collection do
      post 'add_items'
    end

    member do
      post 'clear'
      get 'concordance_search'
      get 'frequency_search'
      get 'download_config_file'
      get 'download_item_list'
      post 'share'
      post 'unshare'
      post 'aspera_transfer_spec'
    end
  end

  # resources :media_items, :transcripts
  match '/eopas/:collection/:itemId' => 'transcripts#show', :as => 'eopas', :constraints => catalogRoutesConstraints

  match 'schema/json-ld' => 'catalog#annotation_context', :as => 'annotation_context'
  resources :issue_reports, :only => [:new, :create] do
  end

  get "document_audit", :to => 'admin#document_audit', :as => 'document_audit'
  get "document_audit/download", :to => 'admin#document_audit_download', :as => 'download_document_audit'

  match 'licences' => 'licences#index'

  resources :admin, :only => [:index] do
    collection do

      resources :users, :only => [:index, :show], :path => "/users" do
        collection do
          get :access_requests
          get :index
          get :admin
          post :accept_licence_terms
          post :send_licence_request
        end
        member do
          put :reject
          put :reject_as_spam
          put :deactivate
          put :activate
          get :edit_role
          put :update_role
          get :edit_approval
          put :approve
        end
      end

      resources :collections, :only => [:new, :create], :path => "/collections" do
        collection do
          post 'add_licence_to_collection'
          put 'change_collection_privacy'
          put 'revoke_access'
        end
      end

      resources :collection_lists, :only => [:index, :show, :new, :create, :destroy] do
        collection do
          post 'add_collections'
          post 'add_licence_to_collection_list'
          get 'remove_collection'
          put 'change_collection_list_privacy'
          put 'revoke_access'
        end
      end

      resources :licences, :only => [:index, :new, :create], :path => "/licences" do
        get :index
      end

      resources :user_licence_requests, :only => [:index], :path => "/collection_requests" do
        member do
          put :approve_request
          put :reject_request
        end
      end


    end
  end
end
