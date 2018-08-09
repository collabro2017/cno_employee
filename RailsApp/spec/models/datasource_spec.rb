require 'spec_helper'

describe Datasource do

  subject(:datasource) { FactoryGirl.build(:datasource) }
  
  #--------------------------
	it "has a valid Factory" do
		expect(datasource).to be_valid
	end
	#--------------------------

  # associations  
  it { is_expected.to respond_to(:counts) }
  it { is_expected.to respond_to(:concrete_fields) }
	it { is_expected.to respond_to(:fields) }

  # validations 
  it { is_expected.to validate_presence_of(:name) }
    
  context "when the name has symbols" do
    it "is NOT valid" do
      datasource.name = "name@#!&$"
      expect(datasource).to be_invalid
    end
  end
  
  context "when the name has upper case letters" do
    it "is NOT valid" do
      datasource.name = "Valid_Name"
      expect(datasource).to be_invalid
    end
  end
  
  context "when the name has lower case letters, underscores and numbers" do
    it "is valid" do
      datasource.name = "valid_name2"
      expect(datasource).to be_valid
    end    
  end

  # columns
  it { is_expected.to respond_to(:total_records) }

  # methods  
  describe "#datafile_class" do
    context "when it has NOT been saved (and lacks an id)" do
      it "returns nil" do
        expect(datasource.datafile_class).to be_nil
      end
    end
    
    context "when it has been saved (and has an id)" do
      before do
        datasource.save!
      end
      
      it "returns a new class that is a child of DatafilesDatabase::Base" do
        parent = datasource.datafile_class.superclass
        expect(parent).to be DatafilesDatabase::Base
      end
      
      it "returns a class name which name includes its id" do
        expect(datasource.datafile_class.name).to eq "Datafile#{datasource.id}"
      end
    end
  end

  describe "#concrete_field_categories" do
    let(:result) { datasource.concrete_field_categories }
    
    it "returns an ActiveRecord::Relation" do
      expect(result).to be_a ActiveRecord::Relation
    end

    context "when it has concrete_fields" do
      let(:categories) { ["Books", "Philosophy", "Games"] }

      before do
        datasource.save!
        categories.each do |category_name|
          category = FactoryGirl.build(:field_category, name: category_name)
          3.times do
            FactoryGirl.create(
              :concrete_field, field_category: category, datasource: datasource
            )
          end
        end
      end
    
      it "returns field_categories of its concrete_fields sorted by name" do
        expect(result.pluck(:name)).to eq categories.sort
      end

      it "does NOT return field_categories not seen in its concrete_fields" do
        category_name = "Movies"
        category = FactoryGirl.build(:field_category, name: category_name)
        FactoryGirl.create(:concrete_field, field_category: category)
        expect(result.pluck(:name)).to_not include category_name
      end
    end
  end

  describe '#default_output_layout' do
    let(:result_as_array) { subject.default_output_layout.to_a }

    let(:not_in_default) do
      5.times.map do
        FactoryGirl.create(:concrete_field)
      end
    end

    before do
      subject.save!
      not_in_default.each { |cf| subject.concrete_fields << cf }
    end

    context 'when some concrete_fields have default_output_layout != nil' do
      let(:in_default) do
        3.downto(1).map do |i|
          concrete_field = FactoryGirl.create(:concrete_field)
          concrete_field.position = (3 - i)
          concrete_field.default_output_layout = i
          concrete_field
        end
      end

      before do
        in_default.each { |cf| subject.concrete_fields << cf }
      end

      it 'returns the concrete_fields having default_output_layout != nil' do
        expect(result_as_array).to match_array in_default.to_a
      end

      it 'returns them sorted by default_output_layout' do
        in_default.sort! { |cf| cf.default_output_layout }
        expect(result_as_array).to eq in_default.to_a
      end
    end

    context 'when all concrete_fields have default_output_layout = nil' do
      it 'returns an empty relation' do
        expect(result_as_array).to be_empty
      end
    end
  end

end

