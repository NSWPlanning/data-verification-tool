class AuthenticatedController < ApplicationController
  before_filter :require_login

  skip_before_filter :verify_authenticity_token, :if => :api_request?

  skip_before_filter :require_login, :if => :api_request?

  before_filter :require_http_auth, :if => :api_request?

  def api_actions
    []
  end

  def api_request?
    (api_actions.include?(self.action_name.to_sym) && request.format.json?)
  end

  def require_http_auth
    authenticate_with_http_basic do |username, password|
      current_user = login(username, password)
    end

    render :nothing => true, :status => :forbidden unless current_user
  end

  def not_authenticated
    redirect_to login_url
  end

  protected

  def current_role
    current_user.admin? ? :admin : :default
  end

end
