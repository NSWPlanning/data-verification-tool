class ApplicationController < ActionController::Base

  attr_writer :title

  protect_from_forgery

  helper_method :title

  def title
    @title ||= controller_name.humanize
  end
end
