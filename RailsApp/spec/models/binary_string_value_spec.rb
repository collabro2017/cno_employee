require 'spec_helper'

describe BinaryStringValue do

  subject(:bin_string_value) { FactoryGirl.build(:binary_string_value) }
  
  #--------------------------
  it "has a valid Factory" do
    expect(bin_string_value).to be_valid
  end
  #--------------------------

  it { should validate_presence_of(:concrete_field) }
  
  it { should respond_to(:on_value) }
  it { should respond_to(:off_value) }
  it { should respond_to(:on_count) }
  it { should respond_to(:off_count) }

end
