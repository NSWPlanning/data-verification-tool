require 'spec_helper'

describe '/heartbeat' do

  specify do

    visit '/heartbeat'
    page.should have_content 'ok'

  end

end
