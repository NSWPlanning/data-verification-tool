require 'spec_helper'

describe ProfilesController do

  let(:user)  { FactoryGirl.create(:user) }

  before do
    login_user user
  end

  describe '#edit' do

    specify do
      get :edit
      assigns[:profile].should == user
      assigns[:title].should == 'Edit profile'
    end

  end

  describe '#update' do

    let(:user_attributes) { {'foo' => 'bar'} }

    context 'when successful' do
      specify do
        user.should_receive(:update_attributes).with(user_attributes) { true }
        put :update, :user => user_attributes
        assigns[:profile].should == user
        response.should redirect_to(root_url)
      end
    end

    context 'when unsuccessful' do
      specify do
        user.should_receive(:update_attributes).with(user_attributes) { false }
        put :update, :user => user_attributes
        assigns[:profile].should == user
        response.should render_template('edit')
      end
    end

  end

end
