module ResourceController

  def self.included(base)
    base.respond_to :html
  end

  def index
    set_collection_ivar model.all # @foos = Foo.all
  end

  def show
    model = set_singular_ivar(find_model(params[:id])) # @foo = Foo.find(id)
    @title = model.to_s
  end

  def new
    @title = "Create new #{human_singular_name}"
    respond_with set_singular_ivar(model.new) # @foo = Foo.new
  end

  def create
    @title = "Create new #{human_singular_name}"
    instance = set_singular_ivar(model.new) # @foo = Foo.new
    instance.assign_attributes(instance_params, :as => current_role)
    instance.save
    respond_with instance
  end

  def edit
    instance = set_singular_ivar(find_model(params[:id])) # @foo = Foo.find(id)
    @title = "Edit #{human_singular_name} #{instance}"
  end

  def update
    instance = set_singular_ivar(find_model(params[:id])) # @foo = Foo.find(id)
    instance.assign_attributes(instance_params, :as => current_role)
    instance.save
    respond_with instance
  end

  protected
  def find_model(id)
    model.find(id)
  end

  # The model for this controller.  For FooBarsController, returns the constant
  # FooBar
  protected
  def model
    controller_name.classify.constantize
  end

  # Returns the human readable singular name for this resource, so for
  # FooBarsController returns 'foo bar'.
  protected
  def human_singular_name
    controller_name.singularize.humanize.downcase
  end
  #
  # Returns the singular name for this resource, with underscores instead of
  # spacesm so for FooBarsController returns 'foo_bar'.
  protected
  def singular_name
    controller_name.singularize
  end

  protected
  def instance_params
    params[singular_name]
  end

  # Sets an instance variable with the correct name for a collection of
  # instances on this controller, so for FooBarsController this will set
  # @foo_bars = value
  protected
  def set_collection_ivar(value)
    instance_variable_set("@#{controller_name}", value)
  end

  # Sets an instance variable with the correct name for a singular instance of
  # the model for this controller, so for FooBarsController this will set
  # @foo_bar = value
  protected
  def set_singular_ivar(value)
    instance_variable_set("@#{controller_name.singularize}", value)
  end

end
