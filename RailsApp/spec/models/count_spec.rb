require 'spec_helper'

describe Count do

  subject(:count) { FactoryGirl.build(:count) }

  #--------------------------
	it "has a valid Factory" do
		expect(count).to be_valid
	end
	#--------------------------

  it { should respond_to(:name) }
  it { should respond_to(:datasource) } 
  it { should respond_to(:result) }

  it { should respond_to(:selects) }
  it { should respond_to(:breakdowns) }
  it { should respond_to(:dedupes) }
  
  it { should respond_to(:jobs) }
  it { should respond_to(:last_breakdown_job) }
  
  describe "#values_class" do
    context "when it doesn't have an id" do
      its(:values_class) { should be_nil }
    end

    context "when it has an id" do
      before { count.id = 42; count.save; }
      
      it "returns the right class" do
        expect(count.values_class).to be "Count42Value".constantize
      end
    end  
  end

  context "when the name is too long" do
    before { count.name = "a" * (64 + 1) }
    it { should_not be_valid }
  end

  context "when the name is too short" do
    before { count.name = "" }
    it { should_not be_valid }
  end

  context "when the name has invalid characters" do
    before { count.name = '\:*?"<>|' }
    it { should_not be_valid }
  end

  context "when the name has leading or trailing spaces" do
    let(:name) { "Some Name" }
    
    shared_examples "strips the name" do
      it "removes the leading or trailing spaces" do
        count.save!
        expect(count.name).to eq name
      end
    end
    
    context "when the name has trailing spaces" do
      before { count.name = " #{name}" }
      it_behaves_like "strips the name"
    end

    context "when the name has trailing spaces" do
      before { count.name = "#{name} " }
      it_behaves_like "strips the name"
    end
  end

  context 'when its name has been already used' do
    context 'when the name is been used by an exact clone' do
      before do
        count_with_same_name = count.dup
        count_with_same_name.save!
      end

      it { should_not be_valid }
    end
    
    context 'when the name that was already used belongs to itself' do
      before { count.save! }
      it { should be_valid } 
    end

    context 'when the count with the same name belongs to a different user' do
      let(:second_user) { FactoryGirl.create(:user) }

      before do
        count_with_same_name = count.dup
        count_with_same_name.user = second_user
        count_with_same_name.save
      end

      it { should be_valid }
    end
  end

  context 'when the name is nil' do
    before { count.name = nil; count.save! }
    
    it 'generates a default name' do
      expect(count.name).to eq "New Count"
    end    
  end

  describe "with a negative result" do
    before { count.result = -1 }
    it { should_not be_valid }
  end

  shared_examples "that depends on the selects and their state" do |method|  
    shared_examples "doesn't have selects or any select is active" do
      case method
      when :active_selects
        it "returns a query that results in an empty record set" do
          expect(count.active_selects).to be_empty
        end
      when :select_queries
        it "returns an empty relation" do
          input = count.active_selects.to_a
          expect(count.select_queries(input)).to be_empty
        end
      when :fast_create_dedupe_temp
        it "returns nil" do
          expect(count.fast_create_dedupe_temp).to be_nil
        end
      when :fast_dedupe_last_query
        it "returns nil" do
          expect(count.fast_dedupe_last_query).to be_nil
        end
      when :fast_results_table_name
        it "returns nil" do
          expect(count.fast_results_table_name).to be_nil
        end
      when :new_count_tasks
        it "returns an empty Array" do
          expect(count.new_count_tasks).to be_empty
        end
      end
    end
    
    n = 4 # Maximum number of selects to test
    context "when it has #{n} selects" do
      let!(:selects) do
        count.save!
        Array.new(n).map.with_index do |value, i| 
          field = FactoryGirl.create(:field, name: "field#{i}")
          cf = FactoryGirl.create(:concrete_field,
              field: field,
              datasource: count.datasource,
              db_data_type: :integer,
              min: 0,
              max: 100)
          FactoryGirl.create(:select,
              position: i,
              count: count,
              concrete_field: cf
            )
        end
      end

      examples = (1..n).map { |i| (0...n).to_a.combination(i).to_a }.flatten(1)
      examples.each do |indices|
        indices_sentence = indices.map { |i| (i+1).ordinalize }.to_sentence
        verb_to_be = (indices.size > 1) ? "are" : "is"
        
        context "when the #{indices_sentence} #{verb_to_be} active" do
          before do
            indices.each do |index|
              case index
              when 1 # active only because has a range 
                selects[index].from = 1
                selects[index].to = 10
                selects[index].save!
              when 2 # active because has range and value
                selects[index].from = 1
                selects[index].to = 10
                selects[index].save!
                selects[index].add_value(value: index.to_s, input_method: :check)
                selects[index].class.connection.commit_db_transaction
              else # cases 0 or else: active only because has a value           
                selects[index].add_value(value: index.to_s, input_method: :check)
                selects[index].class.connection.commit_db_transaction
              end
            end
            
            # Stub the sorted active selects
            count.stub(:sorted_active_selects).and_return(
              indices.inject([]) { |memo, index| memo << count.selects[index] }
            )
          end
        
          after do
            DatabaseCleaner.clean_with(:truncation)
            ProcessDatabase::Base.truncate_all_tables
          end      

          case method
          when :active_selects
            it "returns only the #{indices_sentence}" do
              expected_result = indices.map{ |i| selects[i].id }
              result = count.active_selects.pluck(:id)
              expect(result).to eq expected_result
            end

          when :select_queries
            let(:queries) do 
              count.select_queries(count.active_selects.to_a)
            end

            it "returns an array with #{indices.size} queries" do
              expect(queries.size).to eq (indices.size)
            end

          when :fast_create_dedupe_temp
            let(:source) { "`process_test`.count#{count.id}_partial_result" }

            [true, false].each do |is_keycoded|
              context "when the concrete_field.keycoded == #{is_keycoded}" do
                let(:criteria_table) do
                  ded = count.dedupes.first
                  "#{ded.concrete_field.column_table}"
                end
                
                let(:criteria_value) do
                  if is_keycoded
                    "#{criteria_table}.value_id as dedupe_criteria"
                  else
                    "#{criteria_table}.value as dedupe_criteria"
                  end
                end

                let(:criteria_id) do
                  "#{criteria_table}.id"
                end

                let(:dedupe_temp_table_header) do
                  "`process_test`.count#{count.id}_temp_dedupe"
                end

                context "when there are NO tiebreakers" do
                  before do
                    cf = FactoryGirl.create(:concrete_field,
                      name: "concrete_field1",
                      keycoded: is_keycoded == true ? true : nil)

                    ded = FactoryGirl.create(:dedupe,
                      concrete_field: cf,
                      count: count)
                  end

                  specify "it has 1 dedupe only" do
                    expect(count.dedupes.size).to eq 1
                  end

                  it "returns the extraction query" do
                    sql = <<-END_SQL.strip_heredoc
                      CREATE TABLE <%= dedupe_temp_table_header %> (
                        SELECT
                          <%= criteria_id %>,
                          <%= criteria_value %>
                        FROM
                          <%= source %>
                          INNER JOIN <%= criteria_table %>
                            ON <%= source %>.id = <%= criteria_id %>
                      );
                    END_SQL

                    expectation = ERB.new(sql).result(binding)
                    expect(count.fast_create_dedupe_temp).to eq expectation
                  end
                end

                context "when there are tiebreakers" do
                  before do
                    [1,2,3,4].map do |i|
                      cf = FactoryGirl.create(:concrete_field,
                          name: "concrete_field#{i}",
                          keycoded: is_keycoded == true ? true : nil)
                      ded = FactoryGirl.create(:dedupe,
                          concrete_field: cf,
                          count: count,
                          tiebreak: i.even? ? "MAX" : "MIN")
                    end
                  end

                  let(:dedupes_order_clause) do
                    fields = count.dedupes.map do |ded|
                      if is_keycoded
                        tb = "#{ded.concrete_field.column_table}_values.value"
                        direction = ded.tiebreak == 'MAX' ? 'DESC' : 'ASC' 
                        "#{tb} #{direction}"
                      else
                        tb = "#{ded.concrete_field.column_table}.value"
                        direction = ded.tiebreak == 'MAX' ? 'DESC' : 'ASC' 
                        "#{tb} #{direction}"
                      end
                    end
                    fields.drop(1).compact.join(",\n")
                  end

                  specify "it has 2 or more dedupes" do
                    expect(count.dedupes.size).to be > 1
                  end

                  it "returns the extraction query" do
                    sql = <<-END_SQL.strip_heredoc
                      CREATE TABLE <%= dedupe_temp_table_header %> (
                        SELECT
                          <%= criteria_id %>,
                          <%= criteria_value %>
                        FROM
                          <%= source %>
                          INNER JOIN <%= criteria_table %>
                            ON <%= source %>.id = <%= criteria_id %>
                          <% count.dedupes.drop(1).each do |ded| %>
                            <%= ded.record_extraction_inner_sql %>
                          <% end %>
                        ORDER BY
                          <%= dedupes_order_clause %>
                      );
                    END_SQL

                    expectation = ERB.new(sql).result(binding)
                    expect(count.fast_create_dedupe_temp).to eq expectation
                  end
                end
              end
            end # [true, false].each

          when :fast_dedupe_last_query
            let(:source) { "`process_test`.count#{count.id}_temp_dedupe" }
            
            context "when the count has selects with values" do
              let(:temp_table) { "`process_test`.count#{count.id}_result" }

              it "returns the last query" do
                sql = <<-END_SQL.strip_heredoc
                  CREATE TABLE <%= temp_table %> (
                    SELECT
                      id
                    FROM
                      <%= source %>
                    GROUP BY
                      dedupe_criteria
                  );
                END_SQL

                expectation = ERB.new(sql).result(binding)
                expect(count.fast_dedupe_last_query).to eq expectation
              end
            end

          when :fast_results_table_name
            context 'when there are active selects' do
              it 'returns the result table name' do  
                expected = "`process_test`.count#{count.id}_result"
                expect(count.fast_results_table_name).to eq expected
              end
            end

          when :new_count_tasks
            let(:tasks) { count.new_count_tasks }
            
            let(:select_tasks) do
              tasks.select do |task|
                task.type == :process_binary_field ||
                  task.type == :process_non_binary_field
              end
            end
            
            specify 'the first tasks is of type :set_config_data' do
              expect(tasks.first.type).to eq :set_config_data
            end

            context 'when there are NO dedupes' do
              tasks_count = indices.count + 2

              specify "there are #{tasks_count - 2} tasks related to selects" do
                expect(select_tasks.count).to eq (tasks_count - 2)
              end

              specify "the last task is of type :result_from_bitmap" do
                expect(tasks.last.type).to eq :result_from_bitmap
              end

              specify "there are #{tasks_count} total tasks" do
                expect(tasks.count).to eq tasks_count
              end
            end

            context 'when there ARE dedupes' do
              tasks_count = indices.count + 4
              
              before do
                cf = FactoryGirl.create(:concrete_field, name: 'cf1')
                ded = FactoryGirl.create(:dedupe,
                  concrete_field: cf,
                  count: count)
              end

              let(:dedupe_task) {tasks.select {|t| t.type == :process_dedupe} }

              specify "there are #{tasks_count - 4} tasks related to selects" do
                expect(select_tasks.count).to eq (tasks_count - 4)
              end

              specify "there is 1 task related to dedupes" do
                expect(dedupe_task.count).to eq 1
              end

              specify "the last task is of type :cleanup" do
                expect(tasks.last.type).to eq :cleanup
              end

              specify "there are #{tasks_count} total tasks" do
                expect(tasks.count).to eq tasks_count
              end

            end

          end # case(method)
        end
      end
      
      context "when NONE is active" do
        it_behaves_like "doesn't have selects or any select is active"
      end
    end #has selects
    
    context "when it does NOT have selects" do
      it_behaves_like "doesn't have selects or any select is active"
    end  
  end #shared context
  
  [
    :active_selects,
    :select_queries,
    :fast_create_dedupe_temp,
    :fast_dedupe_last_query,
    :fast_results_table_name,
    :new_count_tasks
  ].each do |method|
    RSpec.configure do |c|
      c.alias_it_should_behave_like_to :it_has_behavior, 'has behavior'
    end
    
    describe "##{method}" do
      it_has_behavior "that depends on the selects and their state", method 
    end
  end

################################################################################

  describe "::next_name_for" do
    context "when requested the next name providing a 'possible' name" do  
      let (:possible_name) { "New Count Name" }
      let (:user) { FactoryGirl.create(:user) }

      context "when the 'possible' name doesn't exist" do
        it "should return the same as the 'possible'" do
          Count.next_name_for(possible_name, user.id).should eq possible_name
        end
      end

      context "when the 'possible' name already exists" do
        before do
          FactoryGirl.create(:count, name: possible_name, user_id: user.id)
        end
        
        it "should return the possible name with a number appended" do
          Count.next_name_for(possible_name, user.id)
            .should eq "#{possible_name} (1)"
        end

        context "when the 'possible' name already exists more than once" do
          before do
            FactoryGirl.create(:count, name: "#{possible_name} (1)",
              user_id: user.id)
            FactoryGirl.create(:count, name: "#{possible_name} (5)",
              user_id: user.id)
          end
          it "should return it with the first available number appended" do
            Count.next_name_for(possible_name, user.id)
              .should eq "#{possible_name} (2)"
          end     
        end
      end
    end
  end

end
