require 'spec_helper'

describe Message do
  
  let(:user) { FactoryGirl.create(:user) }
  before { @message = user.messages.build(content: "d #{user.user_name} Lorem ipsum") }


  subject { @message }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:sent_to)}
  its(:user) { should == user }

  it { should be_valid }

  describe "when user_id is not present" do
    before { @message.user_id = nil }
    it { should_not be_valid }
  end

  describe "accessible attributes" do
    it "should not allow access to user_id" do
      expect do
        Message.new(user_id: user.id)
      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end
  describe "with blank content" do
    before { @message.content = " " }
    it { should_not be_valid }
  end

  describe "with content that is too long" do
    before { @message.content = "a" * 501}
    it { should_not be_valid }
  end
end
