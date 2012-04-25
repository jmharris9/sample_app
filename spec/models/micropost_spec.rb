require 'spec_helper'

describe Micropost do

  let(:user) { FactoryGirl.create(:user) }
  before { @micropost = user.microposts.build(content: "Lorem ipsum") }


  subject { @micropost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:in_reply_to)}
  its(:user) { should == user }

  it { should be_valid }

  describe "when user_id is not present" do
    before { @micropost.user_id = nil }
    it { should_not be_valid }
  end

  describe "accessible attributes" do
    it "should not allow access to user_id" do
      expect do
        Micropost.new(user_id: user.id)
      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end
  describe "with blank content" do
    before { @micropost.content = " " }
    it { should_not be_valid }
  end

  describe "with content that is too long" do
    before { @micropost.content = "a" * 141 }
    it { should_not be_valid }
  end
  
  describe "from_users_followed_by" do

    let(:user)       { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    let(:third_user) { FactoryGirl.create(:user) }

    before { user.follow!(other_user) }

    let(:own_post)        {       user.microposts.create!(content: "foo") }
    let(:followed_post)   { other_user.microposts.create!(content: "bar") }
    let(:unfollowed_post) { third_user.microposts.create!(content: "baz") }
   

    subject { Micropost.from_users_followed_by(user) }

    it { should include(own_post) }
    it { should include(followed_post) }
    it { should_not include(unfollowed_post) }


    describe "and in_reply_to" do
      let(:reply_user)  {FactoryGirl.create(:user)}
      let(:reply_post)  {reply_user.microposts.create!(content: "@#{user.user_name} hi", in_reply_to: user.user_name)}
      before {reply_post.parse_micropost}
      subject { Micropost.including_replies(user) }

      it { should include(reply_post) }

      describe "but not in others feed" do

        subject { Micropost.including_replies(other_user)}

        it { should_not include(reply_post)}    
      end
    end
  end

end