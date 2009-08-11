class Document < ActiveRecord::Base
  has_many :collections
  
  has_friendly_id :title, :use_slug => true, :strip_diacritics => true
  
  has_json_object :meta,
    # :schema => [:category, :schema]                 <===   i would like that more
    # :schema => lambda { |o| o.category.schema } #     <===   good enough for now
    
    :after_read => lambda { |d, m|
      d.category.schema.each do |f|
        v = m[f['uid']]
        
        if f['type'] == 'Collection'
          if v.nil? or v == ''
            m[f['uid']] = d.collections.build()
          else
            m[f['uid']] = d.collections.find(v)
          end
        end
      end
      
      m
    }
  
  belongs_to :category
  belongs_to :user
  
  named_scope :order_before, lambda {|order_index| {:conditions => ["order_index < ?", order_index], :limit => 1, :order => "order_index DESC"}}
  named_scope :order_after, lambda {|order_index| {:conditions => ["order_index > ?", order_index], :limit => 1, :order => "order_index ASC"}}
  named_scope :with_parent, lambda {|category| 
    if category.category_id != nil 
      {:conditions => ["category_id = ?", category.category_id ]}
    else
      {:conditions => ["category_id IS NULL"]}
    end
  }
end