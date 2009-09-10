class Document < ActiveRecord::Base
  acts_as_list :scope => :category
  
  has_many :collections, :dependent => :destroy
  has_many :assets, :dependent => :destroy
  
  has_friendly_id :title, :use_slug => true, :strip_diacritics => true
  
  has_json_object :meta,
    # :schema => [:category, :schema]                 <===   i would like that more
    :schema => lambda { |o| o.category.schema }, #    <===   good enough for now
    :after_read => lambda { |d, m|
      d.category.schema.each do |f|
        v = m[f['uid']]
        
        if f['type'] == 'Collection'
          
          if v.nil? or v == ''
            m[f['uid']] = d.collections.build()
          else
            m[f['uid']] = d.collections.find(v)
          end
          
        elsif f['type'] == 'File'
          
          if v.nil? or v == ''
            m[f['uid']] = d.assets.build()
          else
            m[f['uid']] = d.assets.find(v)
          end
          
        end
      end
      
      m
    }
  
  belongs_to :category
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
  named_scope :published, :conditions => { :published => true }
  
  Public_attributes = %W(id title url meta_keywords meta_description meta_title category_id language_id updated_at created_at)
    
  def to_hash
    
    # Convert document to hash
    document_hash = attributes.reject { |key, _| !Public_attributes.include?(key) }
    
    if document_hash['url'] == ""
      document_hash['url'] = to_param
    end
    
    schema = category.schema || []
    if meta
      schema.each do |item|
        # Read value from the document's JSON store and append it to the hash
        name = item['name']
        next if name.empty?
        uid = item['uid']
        value = meta[uid]
        
        # @TODO: Move into model
        value = value.serialize if value.class.respond_to?(:serialize)
        
        document_hash[ name ] = value
      end
    end
    
    document_hash
  end
end