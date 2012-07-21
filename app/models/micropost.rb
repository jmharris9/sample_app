class Micropost < ActiveRecord::Base
  attr_accessible :content, :in_reply_to
  belongs_to :user

  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true  
  
  default_scope order: 'microposts.created_at DESC'

  # Returns microposts from the users being followed by the given user.
  scope :from_users_followed_by,  lambda { |user| followed_by(user) }
  scope :including_replies,       lambda { |user| included_replies(user)}

  scope :search, lambda { |val|  where("content LIKE ?", "%#{val}%") }

  def parse_micropost
      user_regex = /\A\S+/.match(self.content).to_s
      user_regex = user_regex[1..-1]
      self.in_reply_to = user_regex
  end

  private
  # Returns an SQL condition for users followed by the given user.
    # We include the user's own id as well.
    def self.followed_by(user)
      followed_user_ids = %(SELECT followed_id FROM relationships
                            WHERE follower_id = :user_id)
      where("user_id IN (#{followed_user_ids}) OR user_id = :user_id",
            { user_id: user })
    end

    def self.included_replies(user)
      followed_user_ids = %(SELECT followed_id FROM relationships
                            WHERE follower_id = :user_id)
      where("in_reply_to = :user_name OR user_id IN (#{followed_user_ids}) 
                            OR user_id = :user_id", 
                            {user_name: user.user_name, user_id: user})
    end
end

