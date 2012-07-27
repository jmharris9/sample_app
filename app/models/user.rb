# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#
require 'state_machine'

class User < ActiveRecord::Base

  state_machine :confirmed_state, :initial => :unconfirmed do
    
    state :unconfirmed do
      def confirmed?
        false
      end
    end

    state :confirmed do
      def confirmed?
        true
      end
    end

    event :confirm do 
      transition :unconfirmed => :confirmed
    end

  end

	attr_accessible :name, :email, :user_name, :password, :password_confirmation, :notifications
	has_secure_password
	has_many :microposts, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :stocks, dependent: :destroy
	has_many :relationships, foreign_key: "follower_id", dependent: :destroy
	has_many :followed_users, through: :relationships, source: :followed
	before_save :create_remember_token
	has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name:  "Relationship",
                                   dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

	validates :name, presence: true, length: {maximum:50}
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
	 uniqueness: { case_sensitive: false } 
  validates :user_name, presence: true, length: {within: 6..40}, uniqueness: true
	validates_presence_of :password, length: {minimum:6}, on: :create
	validates_presence_of :password_confirmation, presence: true, on: :create

  scope :search, lambda { |val|  where("name LIKE ?", "%#{val}%") }
  

  	def feed
     Micropost.including_replies(self)
  	end

    def message_feed
     Message.user_messages(self)
    end

  	def following?(other_user)
    	relationships.find_by_followed_id(other_user.id)
  	end

  	def follow!(other_user)
   		relationships.create!(followed_id: other_user.id)
  	end

  	def unfollow!(other_user)
    	relationships.find_by_followed_id(other_user.id).destroy
  	end

    def send_password_reset
      generate_token(:password_reset_token)
      self.password_reset_sent_at = Time.zone.now
      save!
      UserMailer.password_reset(self).deliver
    end

    def send_registration_confirmation
      generate_token(:registration_confirmation_token)
      self.registration_confirmation_sent_at = Time.zone.now
      save!
      UserMailer.registration_confirmation(self).deliver
    end

    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while User.exists?(column => self[column])
    end

private

   	def create_remember_token
   		self.remember_token = SecureRandom.urlsafe_base64
   	end
end
