require 'spec_helper'

describe NonStandardInstrumentationZone do

  it { should respond_to :local_government_area }
  it { should respond_to :council_id }
  it { should respond_to :lep_nsi_zone }
  it { should respond_to :lep_si_zone }
  it { should respond_to :lep_name }
  it { should respond_to :date_of_update }

end
