class ResetPasswordsController < ApplicationController
  def create
    @user = User.find_by_email(params[:email])
    @user.deliver_reset_password_instructions! if @user
    redirect_to login_path,
      :notice => 'Password reset instructions have been sent to your email address'
  end

  def edit
    @user = User.load_from_reset_password_token(params[:id])
    if @user
      @token = @user.reset_password_token
    else
      not_authenticated
    end
  end

  def update
    @user = User.load_from_reset_password_token(params[:id])
    if @user
      @token = @user.reset_password_token
      @user.password_confirmation = params[:user][:password_confirmation]
      if @user.change_password!(params[:user][:password])
        auto_login(@user)
        redirect_to root_url, :notice => 'Your password has been updated.'
      else
        render 'edit'
      end
    else
      logger.error 'User.load_from_reset_password_token("%s") failed' % [
        params[:id]
      ]
      not_authenticated
    end
  end
end
