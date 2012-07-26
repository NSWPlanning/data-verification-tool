require 'spec_helper'

describe LocalGovernmentAreasController do

  let(:admin) { FactoryGirl.create(:admin_user) }

  before do
    login_user admin
  end

  describe '#index' do

    let(:local_government_areas) { mock("local_government_areas") }

    before do
      LocalGovernmentArea.stub(:all => local_government_areas)
    end

    specify do
      get :index
      subject.title.should == 'Local government areas'
      assigns[:local_government_areas].should == local_government_areas
      response.should render_template('index')
    end

  end

  describe '#new' do

    let(:local_government_area) { mock_model(LocalGovernmentArea) }

    before do
      LocalGovernmentArea.stub(:new)  { local_government_area }
    end
    
    specify do
      get :new
      subject.title.should == 'Create new local government area'
      assigns[:local_government_area].should == local_government_area
      response.should render_template('new')
    end

  end

  describe '#create' do

    let(:local_government_area)         { mock_model(LocalGovernmentArea) }
    let(:local_government_area_params)  { {} }

    before do
      LocalGovernmentArea.stub(:new)  { local_government_area }
    end

    specify do
      local_government_area.should_receive(:assign_attributes).with(
        local_government_area_params, :as => :admin
      )
      local_government_area.should_receive(:save)
      post :create, :local_government_area => local_government_area_params
      assigns[:local_government_area].should == local_government_area
      response.should redirect_to(
        local_government_area_path(local_government_area)
      )
    end
  end

  describe '#show' do

    let(:id)                    { "42" }
    let(:local_government_area) { mock_model(LocalGovernmentArea) }

    before do
      LocalGovernmentArea.stub(:find).with(id)  { local_government_area }
    end

    specify do
      get :show, :id => id
      subject.title.should == local_government_area.to_s
      assigns[:local_government_area].should == local_government_area
      response.should render_template('show')
    end

  end

  describe '#edit' do

    let(:id)                    { "42" }
    let(:local_government_area) { mock_model(LocalGovernmentArea) }

    before do
      LocalGovernmentArea.stub(:find).with(id)  { local_government_area }
    end

    specify do
      get :edit, :id => id
      subject.title.should == "Edit #{local_government_area}"
      assigns[:local_government_area].should == local_government_area
      response.should render_template('edit')
    end
  end

  describe '#update' do

    let(:id)                            { "42" }
    let(:local_government_area)         { mock_model(LocalGovernmentArea) }
    let(:local_government_area_params)  { {} }

    before do
      LocalGovernmentArea.stub(:find).with(id)  { local_government_area }
    end

    specify do
      local_government_area.should_receive(:assign_attributes).with(
        local_government_area_params, :as => :admin
      )
      local_government_area.should_receive(:save)
      put :update, :id => id, :local_government_area => local_government_area_params
      assigns[:local_government_area].should == local_government_area
      response.should redirect_to(
        local_government_area_path(local_government_area)
      )
    end

  end
end
