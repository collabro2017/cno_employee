require 'spec_helper'

describe Dedupe do

  subject(:dedupe) { FactoryGirl.build(:dedupe) }
  
  #--------------------------
	it "has a valid Factory" do
		expect(dedupe).to be_valid
	end
	#--------------------------
  
  it { should validate_presence_of(:count) }
  it { should validate_presence_of(:concrete_field) }
  
  it { should respond_to(:caption) }
  it { should respond_to(:tiebreak) }
  
  it_behaves_like "sortable", :count

end
