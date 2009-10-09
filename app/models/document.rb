class Document < ActiveRecord::Base
  
  has_many :collections, :dependent => :destroy, :as => :collectionable
  has_many :assets,      :dependent => :destroy, :as => :assetable
  
  acts_as_list :scope => :category
  
  has_friendly_id :title, :use_slug => true, :strip_diacritics => true
  
  has_json_store :meta, :schema => [:category, :schema]
  
  belongs_to :category, :counter_cache => true
  belongs_to :user
  
  named_scope :order_before, lambda {|position| {:conditions => ["position < ?", position], :limit => 1, :order => "position DESC"}}
  named_scope :order_after, lambda {|position| {:conditions => ["position > ?", position], :limit => 1, :order => "position ASC"}}
  named_scope :with_parent, lambda {|category| 
    if category.category_id != nil 
      {:conditions => ["category_id = ?", category.category_id ]}
    else
      {:conditions => ["category_id IS NULL"]}
    end
  }
  named_scope :published, :conditions => '`documents`.`published` = 1'
  
  Public_attributes = %w(id title url meta_keywords meta_description meta_title category_id language_id updated_at created_at)
    
  def to_public_hash
    
    # Convert document to hash
    document_hash = attributes.reject { |key, _| !Public_attributes.include?(key) }
    
    if document_hash['url'].empty?
      document_hash['url'] = to_param
    end
    
    if meta
      meta.schema.each do |item|
        value = meta.send(item.name)
        
        # @TODO: Move into model
        value = value.serialize if value.class.respond_to?(:serialize)
        
        document_hash[item.name] = value
      end
    end
    
    document_hash
  end
  
  def self.search(keyword, options = { :page => 1, :per_page => 10 })
    query_string = keyword.gsub(/\\/, '\&\&').gsub(/'/, "''").gsub('%', '\%').gsub('_', '\_')
    sql = "select documents.* from documents where
            (documents.title like '%#{query_string}%'
            or documents.meta_json like '%#{query_string}%'
            or documents.meta_title like '%#{query_string}%'
            or documents.meta_keywords like '%#{query_string}%'
            or documents.meta_description like '%#{query_string}%')
            and searchable = 1"
    self.paginate_by_sql sql, options
  end
  
  def publish
    self.published = true
    self.save
  end
  
  def unpublish
    self.published = false
    self.save
  end
end