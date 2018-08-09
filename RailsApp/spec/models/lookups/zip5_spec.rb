require 'spec_helper'

describe Lookups::Zip5 do

  before do
    LookupDummyBuilder.build_table(
      state: :string, city: :string, zip5: :integer
    )
    Lookups::Zip5.table_name = "lookup_dummies"
  end

  after do
    LookupDummyBuilder.destroy_table_if_exists
  end
	
	subject(:zip5) { FactoryGirl.build(:zip5) }

	#--------------------------
	it "has a valid Factory" do
		expect(zip5).to be_valid
	end
	#-------------------------

	it { should respond_to(:zip5) }
	it { should respond_to(:city) }
	it { should respond_to(:state) }

	describe "#zip5_display" do

		context "when the zip5 is '81657'" do
			it "should return it as it is" do
				zip5.zip5 = 81657
				expect(zip5.zip5_display).to eq "81657"
			end
		end

		context "when the zip5 is '501'" do
			it "should return it 0-padded to 5 positions" do
				zip5.zip5 = 501
				expect(zip5.zip5_display).to eq "00501"
			end
		end
	end

end
