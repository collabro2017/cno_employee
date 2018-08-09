require 'spec_helper'

describe ConcreteFieldInputMethod do

  subject(:cf_input_method) { FactoryGirl.build(:concrete_field_input_method) }
  
  #--------------------------
  it "has a valid Factory" do
    expect(cf_input_method).to be_valid
  end
  #--------------------------
  
  it { should respond_to(:position) }
  it { should respond_to(:input_method_type) }

  it { should validate_presence_of(:concrete_field) }
  it { should validate_presence_of(:input_method_type) }
  
  it_behaves_like "sortable", :concrete_field

  describe 'before_save hooks' do
    let(:action) { cf_input_method.save! }

    context "when input_method_type is 'binary'" do
      context "when concrete_field is also binary" do
        it 'is able to save without errors' do
          expect { action }.not_to raise_error
        end
      end

      context "when concrete_field is NOT binary" do
        before { cf_input_method.concrete_field.ui_data_type = :bitmap }

        it 'raises an Error upon saving' do
          expect { action }.to raise_error
        end
      end
    end

    {number_range: :integer, date_range: :date}.each do |key, value|
      context "when input_method_type is '#{key}'" do
        before { cf_input_method.input_method_type = key.to_sym }

        context "when concrete_field's ui_data_type is #{value}" do
          before { cf_input_method.concrete_field.ui_data_type = value }

          it 'is able to save without errors' do
            expect { action }.not_to raise_error
          end
        end

        context "when concrete_field's ui_data_type is NOT #{value}" do
          it 'raises an Error upon saving' do
            expect { action }.to raise_error
          end
        end
      end
    end
  end
end
