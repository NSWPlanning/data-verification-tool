require 'spec_helper'

describe SessionsController do

  describe '#new' do

    let(:user)  { mock_model(User) }

    before do
      User.stub(:new => user)
    end

    it "renders the correct template" do
      get :new
      assigns[:user].should == user
      response.should render_template('new')
    end

  end

  describe '#create' do

    let(:email)     { 'email@example.com' }
    let(:password)  { 'password' }
    let(:user)      { mock_model(User) }

    context "when login is successful" do

      before do
        subject.stub(:login).with(email, password) { user }
      end

      specify do
        post :create, :email => email, :password => password
        assigns[:user].should == user
        flash[:notice].should == 'Login successful'
        response.should redirect_to(root_url)
      end

    end

    context "when login fails" do
      before do
        subject.stub(:login).with(email, password) { nil }
      end

      specify do
        post :create, :email => email, :password => password
        assigns[:user].should be_nil
        flash[:alert].should == 'Invalid email or password'
        response.should render_template(:new)
      end
    end

  end

end
