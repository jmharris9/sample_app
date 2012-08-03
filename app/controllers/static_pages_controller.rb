class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @micropost  = current_user.microposts.build
      @message = current_user.messages.build
      @feed_items = current_user.feed.search(params[:search]).paginate(page: params[:page])
      @message_feed_items = current_user.message_feed.paginate(page: params[:page])
      @stocks = current_user.stocks.search(params[:search]).paginate(page: params[:page])
      @stock  = current_user.stocks.build
    end
  end
  
  def message_feed
    @message = current_user.messages.build
    @message_feed_items = current_user.message_feed.paginate(page: params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def help
  end 
  
  def about
  end

  def contact
  end

  
end
