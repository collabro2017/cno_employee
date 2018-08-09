require 'spec_helper'

describe Company do

  subject(:company) { FactoryGirl.build(:company) }
  
  #--------------------------
  it "has a valid Factory" do
    expect(company).to be_valid
  end
  #--------------------------

  # associations
  it { is_expected.to have_many :users }

  # validations
  it { is_expected.to validate_uniqueness_of :code }

  # columns
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:code) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:code) }
  
end

