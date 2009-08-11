class User < ActiveRecord::Base
  acts_as_authentic
 
  has_many :categories
  has_many :documents
  has_many :collections
  has_many :images
  
  validates_presence_of :email
  
  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    NineAuthMailer.deliver_password_reset_instructions(self)  
  end
  
  def generate_token
    self.token = rand(36**64).to_s(36)
    self.save
  end
end