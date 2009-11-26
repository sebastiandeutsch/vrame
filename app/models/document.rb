class Document < ActiveRecord::Base
  
  has_many :collections, :dependent => :destroy, :as => :collectionable
  has_many :assets,      :dependent => :destroy, :as => :assetable, :order => "position"
  belongs_to :category, :counter_cache => true
  belongs_to :user
  
  acts_as_list :scope => :category
  
  has_friendly_id :title, :use_slug => true, :strip_diacritics => true
  
  has_json_store :meta, :schema => [:category, :schema]
  
  
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
  named_scope :by_language, lambda { |language| { :conditions => { :language_id => language.id } } }
  
  validates_presence_of :title
  
  Public_attributes = %w(id title url meta_keywords meta_description meta_title category_id language_id updated_at created_at)
  
  def meta_hash
    
    meta_hash = {}
    
    if meta
      meta.schema.fields.each do |field|
        value = meta.send(field.name)
        
        # @TODO: Move into model
        value = value.serialize if value.class.respond_to?(:serialize)
        
        meta_hash[field.name] = value
      end
    end
    
    meta_hash
    
  end
  
  def to_public_hash
    
    # Convert document to hash, only accept some attributes
    document_hash = attributes.reject { |key, _| !Public_attributes.include?(key) }
    
    # Set url
    document_hash['url'] = to_param if document_hash['url'].blank?
    
    # Mix in JSON store items
    document_hash.merge!(meta_hash)

  end
  
  def self.search(keyword, options = { :page => 1, :per_page => 10, :language => nil })
    query_string = keyword.gsub(/\\/, '\&\&').gsub(/'/, "''").gsub('%', '\%').gsub('_', '\_')
    
    where = "(documents.title like '%#{query_string}%'
    or documents.meta_json like '%#{query_string}%'
    or documents.meta_title like '%#{query_string}%'
    or documents.meta_keywords like '%#{query_string}%'
    or documents.meta_description like '%#{query_string}%')
    and searchable = 1"
    where = "#{where} and document.language_id = #{language.id}" if not language.nil?
    
    sql = "select documents.* from documents where #{where}"
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
  
  def render_options
    returning(Hash.new) do |options|
      options[:template] = self.template.blank? ? category.document_template : self.template
      options[:layout]   = self.layout.blank?   ? category.document_layout   : self.layout
      options.delete_if {|key, value| value.blank?}
    end
  end
end