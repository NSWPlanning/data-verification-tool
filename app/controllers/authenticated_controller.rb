class AuthenticatedController < ApplicationController
  before_filter :require_login

  def not_authenticated
    redirect_to login_url
  end
end
