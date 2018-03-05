# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20171016004643) do

  create_table "attachments", :force => true do |t|
    t.string   "file"
    t.string   "file_name"
    t.string   "content_type"
    t.integer  "file_size"
    t.string   "created_by"
    t.integer  "collection_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "attachments", ["collection_id"], :name => "index_attachments_on_collection_id"

  create_table "bookmarks", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "user_type"
  end

  create_table "collection_lists", :force => true do |t|
    t.string   "name"
    t.boolean  "private"
    t.integer  "licence_id"
    t.integer  "owner_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "collection_properties", :force => true do |t|
    t.string   "property"
    t.text     "value"
    t.integer  "collection_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "collections", :force => true do |t|
    t.string   "uri"
    t.text     "text"
    t.string   "name"
    t.boolean  "private"
    t.integer  "owner_id"
    t.integer  "collection_list_id"
    t.integer  "licence_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "contribution_mappings", :force => true do |t|
    t.integer  "contribution_id"
    t.integer  "item_id"
    t.integer  "document_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "contribution_mappings", ["contribution_id", "document_id"], :name => "index_contribution_mappings_on_contribution_id_and_document_id", :unique => true
  add_index "contribution_mappings", ["contribution_id"], :name => "index_contribution_mappings_on_contribution_id"
  add_index "contribution_mappings", ["document_id"], :name => "index_contribution_mappings_on_document_id"
  add_index "contribution_mappings", ["item_id"], :name => "index_contribution_mappings_on_item_id"

  create_table "contributions", :force => true do |t|
    t.string   "name"
    t.integer  "owner_id"
    t.integer  "collection_id"
    t.text     "description"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "contributions", ["collection_id"], :name => "index_contributions_on_collection_id"
  add_index "contributions", ["name"], :name => "index_contributions_on_name", :unique => true
  add_index "contributions", ["owner_id"], :name => "index_contributions_on_owner_id"

  create_table "document_audits", :force => true do |t|
    t.integer  "document_id"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "documents", :force => true do |t|
    t.string   "file_name"
    t.string   "file_path"
    t.string   "doc_type"
    t.string   "mime_type"
    t.integer  "item_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "documents", ["file_name"], :name => "index_documents_on_file_name"
  add_index "documents", ["file_path"], :name => "index_documents_on_file_path"
  add_index "documents", ["item_id"], :name => "index_documents_item_id"

  create_table "item_lists", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "shared"
  end

  create_table "item_metadata_field_name_mappings", :force => true do |t|
    t.string   "solr_name"
    t.string   "rdf_name"
    t.string   "user_friendly_name"
    t.string   "display_name"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "item_metadata_field_name_mappings", ["solr_name"], :name => "index_item_metadata_field_name_mappings_on_solr_name", :unique => true

  create_table "items", :force => true do |t|
    t.string   "uri"
    t.string   "handle"
    t.string   "primary_text_path"
    t.string   "annotation_path"
    t.integer  "collection_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.datetime "indexed_at"
    t.text     "json_metadata"
  end

  add_index "items", ["handle"], :name => "index_items_on_handle", :unique => true
  add_index "items", ["uri"], :name => "index_items_on_uri"

  create_table "items_in_item_lists", :force => true do |t|
    t.integer  "item_list_id"
    t.string   "handle"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "items_in_item_lists", ["item_list_id"], :name => "index_items_in_item_lists_on_item_list_id"

  create_table "languages", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "licences", :force => true do |t|
    t.string   "name"
    t.text     "text"
    t.integer  "owner_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "private"
  end

  create_table "oauth_access_grants", :force => true do |t|
    t.integer  "resource_owner_id", :null => false
    t.integer  "application_id",    :null => false
    t.string   "token",             :null => false
    t.integer  "expires_in",        :null => false
    t.text     "redirect_uri",      :null => false
    t.datetime "created_at",        :null => false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], :name => "index_oauth_access_grants_on_token", :unique => true

  create_table "oauth_access_tokens", :force => true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             :null => false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        :null => false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], :name => "index_oauth_access_tokens_on_refresh_token", :unique => true
  add_index "oauth_access_tokens", ["resource_owner_id"], :name => "index_oauth_access_tokens_on_resource_owner_id"
  add_index "oauth_access_tokens", ["token"], :name => "index_oauth_access_tokens_on_token", :unique => true

  create_table "oauth_applications", :force => true do |t|
    t.string   "name",                         :null => false
    t.string   "uid",                          :null => false
    t.string   "secret",                       :null => false
    t.text     "redirect_uri",                 :null => false
    t.string   "scopes",       :default => "", :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "oauth_applications", ["uid"], :name => "index_oauth_applications_on_uid", :unique => true

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "searches", :force => true do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "user_type"
  end

  add_index "searches", ["user_id"], :name => "index_searches_on_user_id"

  create_table "user_annotations", :force => true do |t|
    t.integer  "user_id"
    t.string   "original_filename"
    t.string   "file_type"
    t.integer  "size_in_bytes"
    t.string   "item_identifier"
    t.boolean  "shareable"
    t.string   "file_location"
    t.string   "annotationCollectionId"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  add_index "user_annotations", ["user_id"], :name => "index_user_annotations_on_user_id"

  create_table "user_api_calls", :force => true do |t|
    t.datetime "request_time"
    t.boolean  "item_list"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "user_api_calls", ["user_id"], :name => "index_user_api_calls_on_user_id"

  create_table "user_licence_agreements", :force => true do |t|
    t.string   "licence_id"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "name"
    t.string   "access_type"
    t.string   "collection_type"
  end

  add_index "user_licence_agreements", ["user_id"], :name => "index_user_licence_agreements_on_user_id"

  create_table "user_licence_requests", :force => true do |t|
    t.string   "request_id"
    t.string   "request_type"
    t.boolean  "approved"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "owner_id"
  end

  add_index "user_licence_requests", ["user_id"], :name => "index_user_licence_requests_on_user_id"

  create_table "user_searches", :force => true do |t|
    t.datetime "search_time"
    t.string   "search_type"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "user_searches", ["user_id"], :name => "index_user_searches_on_user_id"

  create_table "user_sessions", :force => true do |t|
    t.datetime "sign_in_time"
    t.datetime "sign_out_time"
    t.integer  "user_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "user_sessions", ["user_id"], :name => "index_user_sessions_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",        :default => 0
    t.datetime "locked_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "status"
    t.integer  "role_id"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "authentication_token"
    t.boolean  "aaf_registered",         :default => false
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
