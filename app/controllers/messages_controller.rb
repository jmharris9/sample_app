class MessagesController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy]
  before_filter :correct_user,   only: [:destroy, :show]
  
  respond_to :js

  def create
    @message = current_user.message.build(params[:message])
    @message.save
    redirect_to root_path
  end

  def destroy
    @message.destroy
    redirect_back_or root_path
  end

  def show
    @messages = @user.messages.paginate(page: params[:page])
    respond_with(@messages) 
  end

  def tester
    @messages = current_user.messages.all
    respond_with(@messages)
  end

private

    def correct_user
      @message = current_user.messages.find_by_id(params[:id])
      redirect_to root_path if @messages.nil?
    end

end