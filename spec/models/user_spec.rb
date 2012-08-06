require 'spec_helper'

describe User do

  describe '#to_s' do

    before do
      subject.name  = 'Dummy User'
      subject.email = 'foo@example.com'
    end

    its(:to_s)  { should == 'Dummy User <foo@example.com>' }

  end

  describe "member_of_local_government_area?" do

    let(:lga1)  { mock("lga1", :id => 1) }
    let(:lga2)  { mock("lga2", :id => 2) }

    before do
      subject.stub(:local_government_area_ids => [1])
    end

    specify do
      subject.member_of_local_government_area?(lga1).should be_true
      subject.member_of_local_government_area?(lga2).should be_false
      subject.member_of_local_government_area?(1).should be_true
      subject.member_of_local_government_area?(2).should be_false
    end

  end

  describe '#admin?' do

    let(:admin) { mock("admin") }

    before do
      subject.stub(:roles?).with(:admin) { admin }
    end

    it 'delegates to roles?' do
      subject.admin?.should == admin
    end

  end

end
