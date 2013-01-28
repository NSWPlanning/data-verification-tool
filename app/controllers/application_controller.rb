class ApplicationController < ActionController::Base

  attr_writer :title

  protect_from_forgery

  helper_method :title

  def title
    @title ||= controller_name.humanize
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
