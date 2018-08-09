require 'spec_helper'

describe Output do
	
  subject(:output) { FactoryGirl.build(:output) }

  #--------------------------
	it "has a valid Factory" do
		expect(output).to be_valid
	end
	#--------------------------

	it { should validate_presence_of(:order) }
  it { should validate_presence_of(:concrete_field) }

  it { should respond_to(:caption) }

  it_behaves_like "sortable", :order

  describe "#record_extraction_inner_sql" do
    
    let(:source_table) { output.concrete_field.column_table }
    let(:source_values_table) { "#{source_table}_values" }
    let(:results_table) { "filter_table" }
    
    before do
      output.order.count.stub(:results_table_name) {"`process_test`.count1_temp1"}
    end

  describe '#escaped_caption' do
    let(:expectation) { "\"#{output.concrete_field.caption}\"" }
    
    it 'returns outputs escaped caption name' do
      expect(output.escaped_caption).to eq expectation
    end
  end

end
