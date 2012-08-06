require 'spec_helper'

describe ResetPasswordsController do

  describe '#new' do

    specify do
      get :new
      response.should be_success
      response.should render_template('new')
    end

  end

  describe '#create' do

    let(:email) { 'foo@example.com' }
    let(:user)  { mock_model(User) }

    context 'when user is found' do

      before do
        User.stub(:find_by_email).with(email) { user }
      end

      specify do
        user.should_receive(:deliver_reset_password_instructions!)
        post :create, :email => email
        assigns[:user].should == user
        response.should redirect_to(login_path)
      end

    end

    context 'when user is not found' do

      before do
        User.stub(:find_by_email).with(email) { nil }
      end

      specify do
        post :create, :email => email
        assigns[:user].should be_nil
        response.should redirect_to(login_path)
      end

    end

  end

  describe '#edit' do

    let(:reset_password_token)  { 'abc123' }
    let(:user)                  { mock_model(User) }

    context 'when token is valid' do

      before do
        User.stub(:load_from_reset_password_token).with(reset_password_token) {
          user
        }
      end

      specify do
        get :edit, :id => reset_password_token
        assigns[:user].should == user
        response.should be_success
        response.should render_template('edit')
      end

    end

    context 'when token is invalid' do

      before do
        User.stub(:find_by_reset_password_token).with(reset_password_token) {
          nil
        }
      end

      specify do
        get :edit, :id => reset_password_token
        response.should_not be_success
        response.should_not render_template('edit')
      end

    end

  end

  describe '#update' do

    let(:reset_password_token)  { 'abc123' }
    let(:password)              { 'password' }
    let(:password_confirmation) { password }
    let(:user)                  { mock_model(User) }
    let(:user_params)           {
      { :password => password, :password_confirmation => password_confirmation }
    }

    context "when reset token is valid" do

      before do
        User.stub(:load_from_reset_password_token).with(reset_password_token) {
          user
        }
        user.should_receive(:password_confirmation=).with(password_confirmation)
      end

      context "when password confirmation matches" do

        before do
          user.should_receive(:change_password!).with(password) { true }
        end

        specify do
          put :update, :id => reset_password_token, :user => user_params
          assigns[:user].should == user
          response.should redirect_to(root_url)
        end

      end

      context "when password confirmation does not match" do

        before do
          user.should_receive(:change_password!).with(password) { false }
        end

        specify do
          put :update, :id => reset_password_token, :user => user_params
          assigns[:user].should == user
          response.should render_template('edit')
        end

      end

    end

    context "when reset token is invalid" do

      before do
        User.stub(:load_from_reset_password_token).with(reset_password_token) {
          nil
        }
      end

      specify do
        put :update, :id => reset_password_token, :user => user_params
        response.should_not be_success
      end

    end

  end

end
