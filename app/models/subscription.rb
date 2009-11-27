class Subscription < ActiveRecord::Base
  has_many :newsletters, :through => :mailings
  
  before_create  :generate_token
  after_create   :send_confirmation!
  before_destroy :send_unsubscribe_message!
  
  validates_presence_of   :email, :first_name, :last_name, :salutation
  validates_uniqueness_of :email
  validates_format_of     :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  
  named_scope :activated, :conditions => { :active => true }
  
  def generate_token
    self.token = rand(36**32).to_s(36)
  end
  
  def send_confirmation!
    NewsletterMailer.deliver_confirmation_request(self)
  end
  
  def confirm!
    self.active = true
    save
    
    NewsletterMailer.deliver_welcome_message(self)
  end
  
  def send_unsubscribe_message!
    NewsletterMailer.deliver_unsubscribe_message(self)
  end
  
  def confirm_url
    "http://#{NineAuthEngine.configuration.host}/subscriptions/#{token}/confirm"
  end
  
  def unsubscribe_url
    "http://#{NineAuthEngine.configuration.host}/subscriptions/#{token}/unsubscribe"
  end
  
  def full_name
    "#{salutation} #{first_name} #{last_name}"
  end
end
