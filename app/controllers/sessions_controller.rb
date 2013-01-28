class SessionsController < ApplicationController

  def new
    @title = 'Log in'
    add_breadcrumb 'Login', ''
    @user = User.new    
  end

  def create
    @title = 'Log in'
    add_breadcrumb 'Login', ''
    @user = login(params[:email], params[:password])
    if @user
      redirect_back_or_to root_url, :notice => 'Login successful'
    else
      flash.now.alert = 'Invalid email or password'
      render :new
    end
  end

  def destroy
    logout
    redirect_to login_path, :notice => 'Logged out'
  end

end
