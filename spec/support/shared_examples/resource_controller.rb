shared_examples "a resource controller for" do |model|

  include ActionView::Helpers::UrlHelper

  describe "#index" do

    let(:collection) { double("collection") }

    before do
      model.stub(:all => collection)
    end

    context 'when collection length is 1' do

      let(:resource_url)  { '/foo/bar' }
      let(:resource)      { double('resource') }
      let(:collection)    { [resource] }

      before do
        collection.stub(:length => 1)
        subject.stub(:url_for).with(resource) { resource_url }
      end

      specify do
        get :index
        response.should redirect_to(resource_url)
      end

    end

    context 'when collection length is not 1' do

      before do
        collection.stub(:length => 2)
      end

      specify do
        get :index
        subject.should have_page_title model.table_name.humanize
        assigns[model.table_name].should == collection
        response.should render_template('index')
      end

    end

  end

  describe "#new" do

    let(:instance)  { mock_model(model) }

    before do
      model.stub(:new) { instance }
    end

    specify do
      get :new
      # Can't test for page title as we play silly buggers with it now
      assigns[model.name.underscore].should == instance
      response.should render_template('new')
    end

  end

  describe "#create" do

    let(:instance)        { mock_model(model) }
    let(:instance_params) { {} }

    before do
      model.stub(:new => instance)
      instance.should_receive(:assign_attributes).with(instance_params, :as => :admin)
      instance.should_receive(:save)
    end

    specify do
      post :create, model.name.underscore => instance_params
      # Can't test for page title as we play silly buggers with it now
      assigns[model.name.underscore].should == instance
    end

  end

  describe '#show' do

    let(:id)  { "42" }
    let(:instance)  { mock_model(model, :to_s => 'Foo') }

    before do
      model.stub(:find).with(id) { instance }
    end

    specify do
      get :show, :id => id
      subject.should have_page_title instance.to_s
      assigns[model.name.underscore].should == instance
      response.should render_template('show')
    end
  end

  describe '#edit' do

    let(:id)  { "42" }
    let(:instance)  { mock_model(model) }

    before do
      model.stub(:find).with(id) { instance }
    end

    specify do
      get :edit, :id => id
      subject.should have_page_title "#{instance}"
      assigns[model.name.underscore].should == instance
      response.should render_template('edit')
    end
  end

  describe '#update' do

    let(:id)  { "42" }
    let(:instance)  { mock_model(model) }
    let(:instance_params) { {} }

    before do
      model.stub(:find).with(id) { instance }
    end

    specify do
      instance.should_receive(:assign_attributes).with(instance_params, :as => :admin)
      instance.should_receive(:save) { true }
      put :update, :id => id, model.name.underscore => instance_params
      assigns[model.name.underscore].should == instance
      response.should redirect_to(url_for(instance))
    end

  end

end
