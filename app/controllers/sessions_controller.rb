class SessionsController < ApplicationController
  
  def new
  end

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password]) 
      if user.confirmed?
        sign_in user
        redirect_back_or user
      else
        flash.now[:error] = "Account Unconfirmed. Please active your account via the email sent to you"
        render 'new'
      end
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
      sign_out
      redirect_to root_path
  end
end
