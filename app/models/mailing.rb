class Mailing < ActiveRecord::Base
  belongs_to :newsletter
  belongs_to :subscription
  
  validates_uniqueness_of :newsletter_id, :scope => :subscription_id
  
  named_scope :undelivered, :conditions => { :delivered => false }
  
  def deliver!
    # Setting flag first to avoid multiple deliveries
    self.delivered = true
    save
    
    NewsletterMailer.deliver_newsletter(self.newsletter, self.subscription)
  end
  
  def self.batch_process!(batch_size = 50)
    mailings_batch = undelivered.scoped(:limit => batch_size)
        
    return if mailings_batch.empty?
    
    mailings_batch.each do |mailing| mailing.deliver! end        
  end
end