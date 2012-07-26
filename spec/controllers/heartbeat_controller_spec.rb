require 'spec_helper'

describe HeartbeatController do

  describe '#index' do

    specify do
      get :index
      response.body.should match(/ok/)
      response.should be_success
    end

  end
end
