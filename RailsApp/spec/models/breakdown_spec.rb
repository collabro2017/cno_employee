require 'spec_helper'

describe Breakdown do

  subject(:breakdown) { FactoryGirl.build(:breakdown) }
  
  #--------------------------
	it "has a valid Factory" do
		expect(breakdown).to be_valid
	end
	#--------------------------
  
  it { should validate_presence_of(:count) }
  it { should validate_presence_of(:concrete_field) }
  
  it { should respond_to(:caption) }
  
  it_behaves_like "sortable", :count

  describe "#record_extraction_inner_sql" do
    
    let(:source_table) { breakdown.concrete_field.column_table }
    let(:source_values_table) { "#{source_table}_values" }
    let(:results_table) { breakdown.count.results_table_name }
    
    before do
      breakdown.count.stub(:results_table_name) {"`process_test`.count1_temp1"}
    end
    
    context "when the breakdown is keycoded" do
      before { breakdown.concrete_field.keycoded = true }

      it "returns the extraction query" do
    
        sql = <<-END_SQL.strip_heredoc
          INNER JOIN <%= source_table %>
            ON <%= results_table %>.id = <%= source_table %>.id
          INNER JOIN <%= source_values_table %>
            ON <%= source_table %>.value_id = <%= source_values_table %>.id
        END_SQL
         
        expectation = ERB.new(sql).result(binding)
        expect(breakdown.record_extraction_inner_sql).to eq expectation
      end
    end

    context "when the breakdown is not keycoded" do
      before { breakdown.concrete_field.keycoded = nil }
      
      it "returns the extraction inner query" do

        sql = <<-END_SQL.strip_heredoc
          INNER JOIN <%= source_table %>
            ON <%= results_table %>.id = <%= source_table %>.id
        END_SQL

        expectation = ERB.new(sql).result(binding)
        expect(breakdown.record_extraction_inner_sql).to eq expectation
      end
    end
  end
end
