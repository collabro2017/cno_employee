require 'spec_helper'

describe Field do
  
  before do
    @field = Field.new()
  end

  subject { @field }

  it { should respond_to(:name) }
  it { should respond_to(:caption) }
  it { should respond_to(:description) }

  describe "without a name" do
    before { @field.name = " " }
    it { should_not be_valid }
  end

  describe "with a name that has invalid characters" do
    it "should not accept symbols" do
      @field.name = "name@#!&$"
      expect(@field).to be_invalid
    end  
    
    it "should not accept uppercase letters" do
      @field.name = "Valid_Name"
      expect(@field).to be_invalid
    end
    
    it "should accept lowercase letters, underscore and numbers" do
      @field.name = "valid_name2"
      expect(@field).to be_valid
    end
  end

  describe "with a name that is too long" do
    before { @field.name = "a" * (64 + 1) }
    it { should_not be_valid }  
  end

  describe "with a description that is too long" do
    before { @field.description = "a" * (512 + 1) }
    it { should_not be_valid }  
  end

  describe "when asked for its caption" do

    context "when the name has acronyms or abbreviations" do

      describe "when the abbreviation is at end" do
        before { @field.name = "local_phone_num" }
        its(:caption) { should eq "Local Phone Number" }
      end

      describe "when the abbreviation is at the beginning" do
        before { @field.name = "est_home_value" }
        its(:caption) { should eq "Estimated Home Value" }
      end

      describe "when the abbreviation is at the middle" do
        before { @field.name = "biz_opp_seeker" }
        its(:caption) { should eq "Business Opportunity Seeker" }
      end

      describe "when it is an acronym" do
        before { @field.name = "dvds_and_videos_buyer" }
        its(:caption) { should eq "DVDs and Videos Buyer" }
      end


    end

    describe "when the name has an apostrophe" do
      before { @field.name = "men_apos_s_apparel_buyer" }
      its(:caption) { should eq "Men's Apparel Buyer" }
    end

    describe "when the acronym is in plural" do
      before { @field.name = "yrs_in_residence" }
      its(:caption) { should eq "Years in Residence" }
    end

    describe "when titleizing the name" do
      before do 
        @field.name = "the_vitamins_are_in_my_fresh_california_raisins"
      end

      its(:caption) do
        should eq "The Vitamins Are in My Fresh California Raisins"
      end
    end


  end

end
