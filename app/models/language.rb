class Language < ActiveRecord::Base
  has_many :templates, :order => :position
  has_many :documents, :order => :position
  
  validates_presence_of :name, :message => 'Das Feld darf nicht leer sein'
  validates_presence_of :iso3_code, :message => 'Das Feld darf nicht leer sein'
  
  named_scope :published, { :conditions => ["published = '1'"] }
end