require 'spec_helper'

describe BinaryIntegerValue do
  
  subject(:bin_integer_value) { FactoryGirl.build(:binary_integer_value) }
  
  #--------------------------
  it "has a valid Factory" do
    expect(bin_integer_value).to be_valid
  end
  #--------------------------

  it { should validate_presence_of(:concrete_field) }
  
  it { should respond_to(:on_value) }
  it { should respond_to(:off_value) }
  it { should respond_to(:on_count) }
  it { should respond_to(:off_count) }

end
