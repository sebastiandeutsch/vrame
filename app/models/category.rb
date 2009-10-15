class Category < ActiveRecord::Base
  
  has_many :documents, :order => :position
  has_many :collections, :dependent => :destroy, :as => :collectionable
  has_many :assets, :order => "position", :dependent => :destroy, :as => :assetable
  
  has_friendly_id :title, :use_slug => true, :strip_diacritics => true
  
  belongs_to :user
  
  acts_as_tree :order => "position", :counter_cache => true
  acts_as_list :scope => :parent
  
  validates_presence_of :title
  
  named_scope :order_before, lambda {|position| { :conditions => ["position < ?", position], :limit => 1, :order => "position DESC" }}
  named_scope :order_after, lambda {|position| { :conditions => ["position > ?", position], :limit => 1, :order => "position ASC" }}
  named_scope :with_parent, lambda {|parent|
    if parent.parent_id != nil 
      {:conditions => ["parent_id = ?", parent.parent_id ]}
    else
      {:conditions => ["parent_id IS NULL"]}
    end
  }
  named_scope :short_navigation, :conditions => { :short_navigation => 1 }
  named_scope :published, :conditions => '`categories`.`published` = 1'
  named_scope :in_navigation, :conditions => '`categories`.`hide_in_nav` IS NULL OR `categories`.`hide_in_nav` != 1'
  
  def self.default_schema_mappings
    @@default_schema_mappings ||= {
      :file       => :asset,
      :collection => :collection,
      :date       => :date,
      :time       => :time,
      :date_time  => :date_time
    }
  end
  
  has_json_schema :schema, :mappings => self.default_schema_mappings
  has_json_store  :meta,   :mappings => self.default_schema_mappings
  
  Public_attributes = %w(id title url meta_keywords meta_description meta_title parent_id language_id updated_at created_at)
  
  def backend_url_path
    '/vrame/' + backend_url
  end
  
  def to_public_hash
    
    # Convert category to hash, only accept some attributes
    category_hash = attributes.reject { |key, _| !Public_attributes.include?(key) }
    
    # Set url
    category_hash['url'] = to_param if category_hash['url'].empty?
    
    category_hash
    
  end
  
  def insignificant?
    documents.empty? and url.empty? and template.empty?
  end
  
  def first_significant_child
    children.find(
      :first,
      :order => :position,
      :conditions => '`published` = 1 AND (`documents_count` > 0 OR `url` IS NOT NULL OR `template` IS NOT NULL)'
    )
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