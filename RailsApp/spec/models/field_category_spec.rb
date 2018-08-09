require 'spec_helper'

describe FieldCategory do

  subject(:field_category) { FactoryGirl.build(:field_category) }

  #--------------------------
	it "has a valid Factory" do
		expect(field_category).to be_valid
	end
	#--------------------------

  it { should respond_to(:concrete_fields) }
  it { should validate_uniqueness_of(:name) }
  
  
  describe "#sorted_concrete_fields_from_datasource" do
    let(:datasource) { FactoryGirl.create(:datasource) }
    let(:result) { subject.sorted_concrete_fields_from_datasource(datasource) }
    
    it "retunrs an Array" do
      expect(result).to be_a Array
    end

    context "when the category does NOT have fields meeting the criteria" do
      it "returns an empty array" do
        expect(result).to be_empty
      end
    end

    context "when the category has concrete fields meeting the criteria" do
      let(:correct_list) { ["Moon Pool, The", "Bad Twin", "Catch-22"] }
      
      before do
        subject.save!

        correct_list.each do |caption|
          FactoryGirl.create(:concrete_field,
              field_category: subject,
              caption: caption, 
              datasource: datasource
            )
        end
        
        incorrect_datasource = FactoryGirl.create(:datasource)
        ["Uncle Tom's Cabin", "Fahrenheit 451", "Animal Farm"].each do |caption|
          FactoryGirl.create(:concrete_field,
              field_category: subject,
              caption: caption, 
              datasource: incorrect_datasource
            )
        end
      end
      
      it "returns only those that meet the criteria sorted by Caption" do
        expect(result.map(&:caption)).to eq correct_list.sort
      end
    end    
  end
  
  describe "::default" do
    it "returns a field category" do
      expect(FieldCategory.default).to be_a FieldCategory
    end
    
    context "when the default category does not exist" do
      before { FieldCategory.default.destroy! }
      
      it "creates it and returns it" do
        expect(FieldCategory.default).to_not be_nil
      end
    end
  end
  
end
