class Category < ActiveRecord::Base
  TYPES = JsonObject::Types.constants.map {|x| "JsonObject::Types::" + x}
  TYPES_FOR_SELECT = TYPES.map {|t| [t[/\w+$/], t]}
  
  has_many :documents, :order => :position
  belongs_to :parent,
    :class_name => 'Category'
  has_many :collections, :dependent => :destroy, :as => :collectionable
  has_many :assets, :order => "position", :dependent => :destroy, :as => :assetable
  
  has_friendly_id :title, :use_slug => true, :strip_diacritics => true
  
  belongs_to :user
  
  acts_as_tree :order => "position", :counter_cache => true
  acts_as_list :scope => :parent
  before_save  :recalc_position_after_move 
  
  validates_presence_of :title
  
  named_scope :order_before, lambda {|position| { :conditions => ["position < ?", position], :limit => 1, :order => "position DESC" }}
  named_scope :order_after,  lambda {|position| { :conditions => ["position > ?", position], :limit => 1, :order => "position ASC" }}
  named_scope :by_position,  { :order => 'position ASC' }
  named_scope :with_parent,  lambda {|parent|   {:conditions => ["parent_id = ?", parent.id ]} }
  named_scope :short_navigation, :conditions => { :short_navigation => 1 }
  named_scope :published, :conditions => ['`categories`.`published` = ?', true]
  named_scope :in_navigation, :conditions => '`categories`.`hide_in_nav` IS NULL OR `categories`.`hide_in_nav` != 1'
  named_scope :by_language, lambda { |language| { :conditions => { :language_id => language.id } } }
  
  has_json_schema :schema
  has_json_schema :eigenschema
  has_json_store  :meta, :schema => :eigenschema
  
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

private

  def recalc_position_after_move
    add_to_list_bottom if parent_id_changed?
  end
end