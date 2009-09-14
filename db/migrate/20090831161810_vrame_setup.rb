class VrameSetup < ActiveRecord::Migration

  def self.up

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.string   "iso3_code"
    t.boolean  "published",  :default => false
	
    t.integer  "user_id"
	
    t.timestamps
  end

  create_table "categories", :force => true do |t|
    t.string   "title"
	
    t.string   "template"
	
    t.string   "url"
    t.string   "backend_url"
    t.text     "schema_json"
    t.boolean  "inherit_schema"
	
    t.text     "meta_json"
    t.string   "meta_title"
    t.string   "meta_keywords"
    t.text     "meta_description"
	
    t.integer  "position"
	
    t.boolean  "short_navigation"
	
    t.boolean  "published",        :default => false
	
    t.integer  "parent_id"
    t.integer  "language_id"
    t.integer  "user_id"
	
    t.timestamps
  end

  create_table "documents", :force => true do |t|
    t.string   "title"
	
    t.string   "template"
	
    t.string   "url"
    t.string   "backend_url"
	
    t.text     "meta_json"
    t.string   "meta_title"
    t.string   "meta_keywords"
    t.text     "meta_description"
	
    t.integer  "position"
	
    t.boolean  "published",        :default => false
    t.boolean  "searchable",       :default => true
	
    t.integer  "category_id"
    t.integer  "language_id"
	
    t.integer  "user_id"
    t.timestamps
  end

  create_table "collections", :force => true do |t|
    t.string   "title"
    t.text     "meta_json"
	
    t.string   "unique_hash"
	
    t.integer  "language_id"
    t.integer  "user_id"
    t.integer  "document_id"
	
    t.timestamps
  end

  create_table "assets", :force => true do |t|
    t.string   "title"
    t.string   "type"
	
    t.text     "meta_json"
	
    t.text     "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
	
    t.integer  "collection_id"
    t.integer  "language_id"
    t.integer  "user_id"
	
    t.timestamps
  end

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope",          :limit => 40
    t.timestamps
  end

  add_index "slugs", ["name", "sluggable_type", "scope", "sequence"], :name => "index_slugs_on_name_and_sluggable_type_and_scope_and_sequence", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"
  
  end
  
  def self.down
    drop_table "languages"
    drop_table "categories"
    drop_table "documents"
    drop_table "collections"
    drop_table "assets"
    drop_table "slugs"
  end

end
