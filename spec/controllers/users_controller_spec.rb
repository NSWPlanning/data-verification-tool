require 'spec_helper'

describe UsersController do

  let(:admin) { FactoryGirl.create(:admin_user) }

  before do
    login_user admin
  end

  describe "#index" do

    let(:users) { mock("users") }

    before do
      User.stub(:all => users)
    end

    it "renders the correct template" do
      get :index
      subject.title.should == 'Users'
      assigns[:users].should == users
      response.should render_template('index')
    end

  end

  describe "#new" do

    let(:user)  { mock_model(User) }

    before do
      User.stub(:new) { user }
    end

    specify do
      get :new
      subject.title.should == 'Create new user'
      assigns[:user].should == user
      response.should render_template('new')
    end

  end

  describe "#create" do

    let(:user)        { mock_model(User) }
    let(:user_params) { {} }

    before do
      User.stub(:new => user)
      user.should_receive(:assign_attributes).with(user_params, :as => :admin)
      user.should_receive(:save)
    end

    specify do
      post :create, :user => user_params
      subject.title.should == 'Create new user'
      assigns[:user].should == user
    end

  end

  describe '#show' do

    let(:id)  { "42" }
    let(:user)  { mock_model(User, :to_s => 'Foo') }

    before do
      User.stub(:find).with(id) { user }
    end

    specify do
      get :show, :id => id
      subject.title.should == user.to_s
      assigns[:user].should == user
      response.should render_template('show')
    end
  end

  describe '#edit' do

    let(:id)  { "42" }
    let(:user)  { mock_model(User) }

    before do
      User.stub(:find).with(id) { user }
    end

    specify do
      get :edit, :id => id
      subject.title.should == "Edit user #{user.to_s}"
      assigns[:user].should == user
      response.should render_template('edit')
    end
  end

  describe '#update' do

    let(:id)  { "42" }
    let(:user)  { mock_model(User) }
    let(:user_params) { {} }

    before do
      User.stub(:find).with(id) { user }
    end

    specify do
      user.should_receive(:assign_attributes).with(user_params, :as => :admin)
      user.should_receive(:save) { true }
      put :update, :id => id, :user => user_params
      assigns[:user].should == user
      response.should redirect_to(user_path(user))
    end

  end
end
