class RegistrationConfirmationsController < ApplicationController
  def new
  end

  def edit
  	@user = User.find_by_registration_confirmation_token!(params[:id])
  	if @user.registration_confirmation_sent_at < 2.hours.ago
  		@user.destroy
  		redirect_to new_user_path, :alert => "Registration Confirmation has expired."
  	else
  		@user.confirm
  		sign_in @user
        flash[:success] = "Registration Confirmed"
        redirect_to @user
  	end
  end
end
