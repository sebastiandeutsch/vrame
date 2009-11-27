class Newsletter < ActiveRecord::Base  
  before_save :extract_body_plain_text
  
  has_many :subscriptions, :through => :mailings
  has_many :mailings
  
  named_scope :due, :conditions => "dispatched=0 AND publish_on < NOW()"
  
  validates_presence_of :title, :body
  
  include ActionView::Helpers::SanitizeHelper
  extend  ActionView::Helpers::SanitizeHelper::ClassMethods
  
  def send_preview_to(recipient)
    NewsletterMailer.deliver_newsletter(self, recipient)
  end
  
  def schedule_now!
    return if dispatched
    
    @subscriptions = Subscription.activated
    
    @subscriptions.each do |subscription|
      Mailing.create(:newsletter => self, :subscription => subscription)
    end
    
    self.dispatched = true
    self.recipients = @subscriptions.size
    
    save
  end
  
  def title_for(recipient)
    personalize_for(recipient, title)
  end
  
  def body_for(recipient)
    personalize_for(recipient, body)
  end
  
  def body_plain_text_for(recipient)
    personalize_for(recipient, body_plain_text)
  end
  
  ATTRIBUTE_PLACEHOLDERS = {
    /\$ANREDE/        => :salutation,
    /\$VORNAME/       => :first_name,
    /\$NACHNAME/      => :last_name,
    /\$ABMELDUNG_URL/ => :unsubscribe_url
  }
  
  def personalize_for(recipient, text)
    if recipient.class == Subscription
      ATTRIBUTE_PLACEHOLDERS.each do |placeholder, attribute|
         text.gsub!(placeholder, recipient.send(attribute))
      end
    end
    
    return text
  end
  
  HTML_REPLACEMENTS = {
    # Line breaks
    /<div><\/?br><\/div>/ => "\n\n",
    
    # List elements
    /<li>([^<]*)<\/li>/   => "- \\1 \n"
  }
  
  def extract_body_plain_text
    self.body_plain_text = body
    
    # Replace HTML with suitable plaintext equivalents
    HTML_REPLACEMENTS.each do |from, to|
       self.body_plain_text.gsub!(from, to)
    end
    
    # Strip remaining HTML tags
    self.body_plain_text = strip_tags(body_plain_text)
  end
end
