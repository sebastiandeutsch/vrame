class Category < ActiveRecord::Base
  has_many :documents, :order => "order_index"
  
  has_friendly_id :title, :use_slug => true, :strip_diacritics => true
  
  belongs_to :user
  
  acts_as_tree :order => "order_index"
  
  validates_presence_of :title
  
  named_scope :order_before, lambda {|order_index| { :conditions => ["order_index < ?", order_index], :limit => 1, :order => "order_index DESC" }}
  named_scope :order_after, lambda {|order_index| { :conditions => ["order_index > ?", order_index], :limit => 1, :order => "order_index ASC" }}
  named_scope :with_parent, lambda {|parent|
    if parent.parent_id != nil 
      {:conditions => ["parent_id = ?", parent.parent_id ]}
    else
      {:conditions => ["parent_id IS NULL"]}
    end
  }
  named_scope :short_navigation, :conditions => { :short_navigation => 1 }
  
  has_json_object :schema,
    :default => [],
    :before_serialize => lambda { |v|
      v.map { |i|
        # Create new UID if nonexistent
        # @TODO move to a static model function (will be part of JsonSchema)
        # @TODO find a better unique hash algo  (will be an auto incrementing primary key ---> JsonSchema will handle this)
        i.merge({'uid' => i['uid'].nil? || i['uid'].empty? ? rand(36**32).to_s(36) : i['uid']})
      } unless v.nil?
    }
  
  has_json_object :meta
  
  def available_parent_categories
    if new_record?
      Category.all
    else
      Category.find(:all, :conditions => ['id != ?', id])
    end
  end
end