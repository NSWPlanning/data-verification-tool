class ApplicationController < ActionController::Base

  attr_writer :title

  protect_from_forgery

  helper_method :title

  def title
    @title ||= controller_name.humanize
  end

  # temp: hook for mini-profiler
  def authorize
    if current_user.is_admin? 
      Rack::MiniProfiler.authorize_request
    end
  end

protected
  def add_breadcrumb name, url = ''
    @breadcrumbs ||= []
    url = eval(url) if url =~ /_path|_url|@/
    @breadcrumbs << [name, url]
  end

  def self.add_breadcrumb name, url, options = {}
    before_filter options do |controller|
      controller.send(:add_breadcrumb, name, url)
    end
  end   
end
