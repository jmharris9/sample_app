class Message < ActiveRecord::Base
  attr_accessible :content, :sent_to
  belongs_to :user

  validates :content, presence: true, length: { maximum: 500 }
  validates :user_id, presence: true  
  
  default_scope order: 'messages.created_at DESC'

  scope :user_messages,       lambda { |user| user_messages(user)}

  def parse_message
  	if  self.content.to_s =~ /\A[d]\s/
        user_regex = /\A[d]\s\S+/.match(self.content).to_s
        user_regex = user_regex[2..-1]
        self.sent_to = user_regex
        name_length = user_regex.length+3
        self.content = self.content[name_length..-1]
    else
      self.sent_to = []
    end
  end


  private
   	def self.user_messages(user)
      where("sent_to = :user_name  OR user_id = :user_id", 
                            {user_name: user.user_name, user_id: user})
    end
end
