class MicropostsController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy]
  before_filter :correct_user,   only: :destroy
  
  def create
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.content.to_s =~ /\A\@/
      @micropost.parse_micropost
      if User.find_by_user_name(@micropost.in_reply_to)
        flash[:success] = "Reply sent!"
        @micropost.save
        redirect_to root_path
      else
        flash[:error] = "No such user: #{@micropost.in_reply_to}!"
        redirect_to root_path
      end
    elsif @micropost.content.to_s =~ /\A[d]\s/
        @message = current_user.messages.build(params[:message])
        @message.content = @micropost.content
        @message.parse_message
        if User.find_by_user_name(@message.sent_to)
          flash[:success] = "Message sent!"
          @message.save
          @micropost.destroy
          redirect_to root_path
        else
          flash[:error] = "No such user: #{@message.sent_to}!"
          redirect_to root_path
        end
    elsif @micropost.save
        flash[:success] = "Micropost created!"
        redirect_to root_path
    else
        @feed_items = []
        flash[:error] = "Micropost error!"
        render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_back_or root_path
  end

  def index
    @microposts = Micropost.search(params[:search])
  end

private

    def correct_user
      @micropost = current_user.microposts.find_by_id(params[:id])
      redirect_to root_path if @micropost.nil?
    end

end