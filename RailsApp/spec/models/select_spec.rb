require 'spec_helper'

describe Select do

  subject(:select) do
    concrete_field = FactoryGirl.create(:concrete_field, min: 0, max: 10)
    FactoryGirl.build(
      :select, concrete_field: concrete_field
    )
  end

  let(:table_name) { select.values_class.table_name }

  #--------------------------
	it 'has a valid Factory' do
		expect(select).to be_valid
	end
	#--------------------------

  # associations
  it { is_expected.to belong_to(:count) }
  it { is_expected.to belong_to(:concrete_field) }

  # validations
  it { is_expected.to validate_numericality_of(:from).only_integer.allow_nil }
  it { is_expected.to validate_numericality_of(:to).only_integer.allow_nil }

  describe "validation of 'from' and 'to' values" do
    pending
  # describe "with a invalid from value" do
  #   context "when the value is less than its allowed minimum" do
  #     before do
  #       select.concrete_field.min = 0
  #       select.from = -10
  #       select.save
  #     end
  #     it { should_not be_valid }
  #   end

  #   context "when the value is greater than its allowed maximum" do
  #     before do
  #       select.concrete_field.max = 100
  #       select.from = 1000
  #       select.save
  #     end
  #     it { should_not be_valid }
  #   end
  # end
  end

  # enums
  it { is_expected.to respond_to(:blanks) }

  # delegated
  it { is_expected.to respond_to(:values_class) }

  it { is_expected.to respond_to(:caption) }
  it { is_expected.to respond_to(:db_data_type) }
  it { is_expected.to respond_to(:ui_data_type) }
  it { is_expected.to respond_to(:default_lookup_class) }
  it { is_expected.to respond_to(:binary_on_value) }
  it { is_expected.to respond_to(:binary_off_value) }

  # modules
  it_behaves_like 'sortable', :count

  # hooks
  # TO-DO:
  #  - Setting defaults when initializing
  #  - Fixing range values and default blanks criterion before saving
  #  - Setting the default binary after creation

  # scopes
  # TO-DO:

  values_arrays = {
                    'string'  => [
                      'Tabula Rasa', 'Walkabout', 'White Rabbit',
                      'House of the Rising Sun', 'The Moth', 'Confidence Man'
                    ],
                    'integer' => %w[4 8 15 16 23 42]
                  }

  lookup_columns = {'string' => :s_value, 'integer' => :i_value}

=begin
  shared_context 'has a range' do
    before do
      select.from = 1
      select.to = 9

      select.stub(:total_records_range_sql).and_return('<TR_RANGE_SQL>')
      select.stub(:filter_range_sql).and_return('FILTER_RANGE_SQL')
    end
  end

  shared_context 'has values' do
  end
=end

  shared_examples 'reports a change in the selects' do
    it "calls the 'update_flags' method" do
      expect(select).to receive(:update_flags)
      invoke
    end
  end

  shared_examples 'does NOT report a change in the selects' do
    it "does NOT call the 'update_flags method'" do
      expect(select).not_to receive(:update_flags)
      begin invoke; rescue ; end
    end
  end

  %w[integer string].each do |db_data_type|
    context "when select.db_data_type = #{db_data_type}" do
      array = values_arrays[db_data_type]
      single_value = array.first
       
      before do
        select.concrete_field.update_column(:db_data_type, db_data_type)
      end

      describe '#add_value' do
        let(:invoke) do
          select.add_value(value: value, input_method: input_method)
        end
        
        ['', '42', "'dharmacakra'", '8.15', '23'].each do |value|
          context "when adding \"#{value}\"" do
            let(:value) { value }
            let(:input_method) { InputMethodType.default.to_s }
            
            if (
              (db_data_type == 'integer' && /\A[+-]?\d+\z/ === value) ||
              (db_data_type == 'string' && value.is_a?(String))
            )
              it 'returns a value' do
                result = invoke
                expect(result).to be_a select.values_class
              end

              specify "\"#{value}\" gets added to the the process table" do
                filters = {
                            "#{db_data_type}_value" => value,
                            :input_method           => input_method
                          }
                expect { invoke }.to change {
                  select.saved_values.where(filters).count
                }.from(0).to(1)
              end                
              
              it_behaves_like 'reports a change in the selects'
            else
              it 'raises a TypeError' do
                expect { invoke }.to raise_error TypeError
              end
              
              it_behaves_like 'does NOT report a change in the selects'
            end
          end
        end

        context "when #{single_value} already exists" do
          let(:value) { single_value }
          let(:input_method) { 'check' }

          let(:criteria) do
            {
              "#{db_data_type}_value" => single_value
            }
          end

          before do
            select.add_value(value: single_value, input_method: 'check')
          end

          context 'when exists with the same input_method' do
            it 'returns the existing one' do
              existing = select.saved_values.find_by(criteria)
              result = invoke
              expect(result).to eq existing
            end
            
            it 'does NOT add the value again' do
              expect { invoke }.to_not change {
                  select.saved_values.where(criteria).count
                }
            end
            
            it_behaves_like 'does NOT report a change in the selects'
          end

          context 'when exists with a different input_method' do
            let(:value) { single_value }
            let(:input_method) { 'enter' }

            it 'returns the new value' do
              existing = select.saved_values.find_by(criteria)
              result = invoke
              expect(result.input_method).to_not eq existing.input_method
            end
            
            it 'adds the value again' do
              expect { invoke }.to change {
                  select.saved_values.where(criteria).count
                }.from(1).to(2)
            end

            it_behaves_like 'reports a change in the selects'
          end
        end
      end #add_value

      describe '#remove_value' do
        let(:inexistent) { {'integer' => '1', 'string' => 'Pilot I'} }
        let(:default_input_method) { InputMethodType.default.to_s }
        let(:value_to_remove) { array[2] }
        let(:invoke) { select.remove_value(criteria) }
        
        before do
          InputMethodType.each do |method|
            array.each do |value|
              select.add_value(value: value, input_method: method.to_s)
            end
          end
        end

        context 'when removing an existing value' do
          let(:criteria) do
            {value: value_to_remove, input_method: default_input_method}
          end
          
          it 'returns the removed value' do
            to_remove = select.saved_values.find_by(
                "#{db_data_type}_value" => value_to_remove,
                :input_method           => default_input_method
              )
            removed = invoke
            expect(removed).to eq to_remove
          end
          
          it 'removes the value' do
            original_count = array.size * InputMethodType.count
            expect { invoke }.to change {
                select.saved_values.count
              }.from(original_count).to(original_count - 1)
          end

          it_behaves_like 'reports a change in the selects'
        end
        
        context "when removing a value that doesn't exist" do
          let(:criteria) do
            {value: inexistent[db_data_type], input_method: default_input_method}
          end

          it 'returns nil' do
            to_remove = select.remove_value(criteria)
            expect(to_remove).to be_nil
          end
          
          it 'does NOT remove the value' do
            expect { select.remove_value(criteria) }.to_not change {
                select.saved_values.count
              }
          end
          
          it_behaves_like 'does NOT report a change in the selects'
        end
      end #remove_value

      describe '#update_single_value' do
        let(:invoke) do
          select.update_single_value(
            value: new_value,
            input_method: InputMethodType.default.to_s
          )
        end

        ['1', 'Y', nil].each do |value|
          context "when updating #{value.inspect}" do
            let(:new_value) { value }
            let(:input_method) { InputMethodType.default.to_s }
            
            # In contrast with add_value, this method accepts nil
            if (
              value.nil? ||
              (db_data_type == 'integer' && /\A[+-]?\d+\z/ === value) ||
              (db_data_type == 'string' && value.is_a?(String))
            )
              context "when there is one saved value" do
                context "when the existing value is #{array.first}" do
                  let(:existing_value) { array.first }

                  before do
                    select.values_class.create!(
                      select: select,
                      input_method: InputMethodType.default.to_s,
                      :"#{db_data_type}_value" => existing_value
                    )
                  end

                  it "updates the value to #{value.inspect}" do
                    expect { invoke }.to change {
                      select.saved_values.where(
                        input_method: input_method,
                        :"#{db_data_type}_value" => new_value
                      ).count
                    }.by(1)
                  end
                
                  it 'returns the value' do
                    expect(invoke).to be_a select.values_class
                  end

                  it_behaves_like 'reports a change in the selects'
                end

                context "when the exisiting value is #{value.inspect}" do
                  before do
                    select.values_class.create!(
                      select: select,
                      input_method: InputMethodType.default.to_s,
                      :"#{db_data_type}_value" => new_value
                    )
                  end

                  specify 'the value remains the same' do
                    expect { invoke }.to_not change { 
                      select
                        .saved_values
                        .find_by(input_method: input_method)
                        .send(:"#{db_data_type}_value")
                    }
                  end

                  it 'returns the value' do
                    expect(invoke).to be_a select.values_class
                  end
                  
                  it_behaves_like 'does NOT report a change in the selects'
                end
              end # there is one saved value

              context "when there aren't saved values" do
                it 'returns nil' do
                  expect(invoke).to be_nil
                end
                
                it_behaves_like 'does NOT report a change in the selects'
              end # there aren't saved value

              context "when there is more than one saved value" do
                before do
                  array.first(2).each do |value|
                    select.add_value(
                      value: value,
                      input_method: InputMethodType.default.to_s
                    )
                  end
                end

                it 'returns nil' do
                  expect(invoke).to be_nil
                end
                
                it_behaves_like 'does NOT report a change in the selects'
              end # there is more than one saved value

            else
              it 'raises a TypeError' do
                expect { invoke }.to raise_error TypeError
              end
              
              it_behaves_like 'does NOT report a change in the selects'
            end
          end
        end
      end #update_single_value

      describe '#add_multiple_lookup_values' do
        include_context 'uses a lookup model'
        column = lookup_columns[db_data_type]

        before do
          array.each do |value| 
            value = value.to_i if db_data_type == 'integer'
            Lookups::LookupDummy.create(column => value)
          end
        end

        lookup_columns.each do |type, column|
          context "when the column of lookup table is #{column}" do
            let(:add_action) do
              select.add_multiple_lookup_values(
                Lookups::LookupDummy.all, column
              )
            end

            let(:add_scoped_action) do
              scope = Lookups::LookupDummy.order(column).limit(3)
              select.add_multiple_lookup_values(scope, column)
            end

            let(:saved) { select.saved_values.lookup.values_array }
            
            if type == db_data_type
              context 'when the scope is all the lookup values' do
                let(:invoke) { add_action }
                
                it "adds all the #{db_data_type} values" do
                  if db_data_type == 'integer'
                    expected = array.map(&:to_i)
                  else
                    expected = array
                  end
                  invoke
                  expect(saved).to match_array expected
                end

                it_behaves_like 'reports a change in the selects'
              end

              context 'when the scope is the first 3 lookup values' do
                let(:invoke) { add_scoped_action }
                
                it "adds the first 3 #{db_data_type} values" do
                  if db_data_type == 'integer'
                    expected = array.map(&:to_i)
                  else
                    expected = array
                  end
                  expected = expected.sort.first(3)
                  invoke
                  expect(saved).to match_array expected
                end

                it_behaves_like 'reports a change in the selects'
              end

              context 'when adding some values more than once' do
                before { add_action }
                let(:invoke) { add_scoped_action }
                
                specify 'all values that have been added are unique' do
                  invoke
                  expect(saved).to match_array saved.uniq
                end

                it_behaves_like 'reports a change in the selects'
              end
            else
              let(:invoke) { add_action }
              
              it 'raises a TypeError' do
                expect { invoke }.to raise_error TypeError          
              end
              
              it_behaves_like 'does NOT report a change in the selects'
            end
          end        
        end
      end #add_multiple_lookup_values

      describe '#remove_multiple_lookup_values' do
        include_context 'uses a lookup model'
        column = lookup_columns[db_data_type]
      
        let(:invoke) { select.remove_multiple_lookup_values(scope, column) }
        let(:survivors) { select.saved_values.lookup.values_array }
      
        before do
          array.each do |value| 
            value = value.to_i if db_data_type == 'integer'
            Lookups::LookupDummy.create(column => value)
          end
          
          select.add_multiple_lookup_values(Lookups::LookupDummy.all, column)
        end

        context 'when the scope is the first 4 lookup values' do
          let(:scope) { Lookups::LookupDummy.order(column).limit(4) }

          it 'returns 4' do
            result = invoke
            expect(result).to eq 4
          end

          specify 'the last 2 values survive' do
            if db_data_type == 'integer'
              expected = array.map(&:to_i)
            else
              expected = array
            end
            expected = expected.sort.drop(4)

            result = invoke
            expect(survivors).to match_array expected
          end
        
          it_behaves_like 'reports a change in the selects'
        end

        context 'when the scope is all lookup values' do
          let(:scope) { Lookups::LookupDummy.all }

          it "returns #{array.size}" do   
            result = invoke
            expect(result).to eq array.size
          end
          
          specify 'the are no survivors' do
            result = invoke
            expect(survivors).to be_empty
          end

          it_behaves_like 'reports a change in the selects'
        end
        
        context 'when the scope is NOT specified' do
          let(:invoke) { select.remove_multiple_lookup_values }
          let(:survivors) { select.saved_values.lookup.values_array }
          
          it 'returns the total number of lookup values that existed' do
            to_be_removed = select.saved_values.lookup.count
            result = invoke
            expect(result).to eq to_be_removed
          end
          
          it 'removes EVERY value' do
            result = invoke
            expect(survivors).to be_empty
          end

          it_behaves_like 'reports a change in the selects'
        end
      end #remove_multiple_lookup_values

      describe '#add_multiple_enter_values' do
        let(:input) { values.join(',') } # default delimiter
        let(:invoke) { select.add_multiple_enter_values(input) }
        
        ["\t", ';', ',',"\n"].each do |delimiter|
          printable_delimiter = case delimiter
                                when "\t" then "TAB (\\t)"
                                when "\n" then "NEW LINE (\\n)"
                                else delimiter
                                end 
          let(:values) do
            if db_data_type == 'integer'
              array.map(&:to_i)
            else
              array              
            end
          end
          let(:input) { values.join(delimiter) }
          
          context "when it is delimited by '#{printable_delimiter}'" do
            it 'adds the values correctly' do
              result = invoke
              added_values = select.saved_values.enter.values_array
              expect(added_values).to match_array values
            end          

            it 'returns something different than nil' do
              result = invoke
              expect(result).not_to be_nil
            end
            
            it_behaves_like 'reports a change in the selects'
          end
        end

        if db_data_type == 'string'
          context 'when it has a mix of delimiters and spaces and blanks' do
            let(:input) { "Tabula Rasa, \nWalkabout; \t\tWhite Rabbit," }
            
            it 'still adds the values correctly' do
              invoke
              added_values = select.saved_values.enter.values_array
              expect(added_values).to match_array array[0...3] 
            end

            it_behaves_like 'reports a change in the selects'
          end
          
          context 'when some values are already added' do
            before do            
              select.add_multiple_enter_values(array.join(','))
            end
            
            context 'when adding the same values again' do
              it 'returns true' do
                result = select.add_multiple_enter_values(array.join(','))
                expect(result).to be_truthy
              end

              it "does NOT call the 'connection.insert' method" do
                expect(select.class.connection).to_not receive(:insert)
                select.add_multiple_enter_values(array.join(','))
              end
              
              it_behaves_like 'does NOT report a change in the selects'
            end

            context 'when adding two new values plus one repeated value' do
              let(:values) { ['Solitary', 'Raised by Another'] << array[0] }

              it 'returns true' do
                result = invoke
                expect(result).to be_truthy
              end

              specify 'all values that have been added are unique' do
                invoke
                added_values = select.saved_values.enter.values_array
                expect(added_values).to match_array (array + values).uniq
              end

              it_behaves_like 'reports a change in the selects'
            end
          end
        elsif db_data_type == 'integer'
          context 'when all values can be converted' do
            let(:values) { [1, 2, 3, 4, 5] }

            it 'converts and adds the values' do
              invoke
              added_values = select.saved_values.enter.values_array
              expect(added_values).to match_array values
            end

            it_behaves_like 'reports a change in the selects'
          end
          
          context 'when there are values that cannot be coverted' do
            let(:input) { '1, a, 2, b, 3, c,' }
            
            it 'raises a TypeError' do
              expect {
                  invoke
                }.to raise_error TypeError
            end
            
            it_behaves_like 'does NOT report a change in the selects'
          end
        end        

        context 'when receives an empty string' do
          let(:values) { [] }
          
          it 'does not add anything' do
            invoke
            expect(select.saved_values.enter.values_array).to be_empty
          end
          
          it_behaves_like 'does NOT report a change in the selects'
        end

        context 'when receives only delimiters and blanks' do
          let(:input) { ", \n; \t\t," }
          
          it 'does not add anything' do
            invoke
            expect(select.saved_values.enter.values_array).to be_empty
          end
          
          it_behaves_like 'does NOT report a change in the selects'
        end 
      end #add_multiple_enter_values

      describe '#saved_lookup_values' do
        include_context 'uses a lookup model'
        column = lookup_columns[db_data_type]        
        before do
          array.each do |value|
            value = value.to_i if db_data_type == 'integer'
            Lookups::LookupDummy.create(column => value)
          end
        end

        it "returns #{db_data_type} values added through 'lookup' within scope" do
          select.add_multiple_lookup_values(Lookups::LookupDummy.all, column)

          scope = Lookups::LookupDummy.order(column).limit(2)
          result = select.saved_lookup_values(scope, column).values_array
          
          if db_data_type == 'integer'
            expected = array.map(&:to_i)
          else
            expected = array
          end
          expected = expected.sort[0..1]
          
          expect(result).to match_array expected
        end
      end #saved_lookup_values

=begin DO NOT DELETE: THIS IS STILL PENDING TO MAKE IT PASS OR REVIEW IF NEEDED
      describe '#saved_binary_value' do
        context 'when the underlying concrete field is of UI type binary' do
          
          possible_values = {
            'integer' => { off: 0, on: 1 },
            'string'  => { off: '', on: '1' }
          }
          
          before do 
            select.concrete_field.update_column(:ui_data_type, 'binary')
            
            select.concrete_field.send(
              :"build_binary_#{db_data_type}_value",
              on_value: possible_values[db_data_type][:on],
              off_value: possible_values[db_data_type][:off]  
            )
          end
          
          context 'when no value is added' do
            it 'returns nil' do
              expect(select.saved_binary_value).to be_nil
            end
          end
          
          possible_values[db_data_type].each do |key, value|
            context "when the '#{key}' value is added" do
              before { select.add_value(value: value, input_method: :check) }

              on_value = possible_values[db_data_type][:on]
              it "returns #{value == on_value}" do
                expect(select.saved_binary_value).to eq value == on_value 
              end
            end
          end      
        end
      
        context 'when the underlying concrete field is NOT of UI type binary' do
          it 'returns nil' do
            expect(select.saved_binary_value).to be_nil
          end
        end  
      end #saved_binary_value

      describe '#value_column' do
        it "returns '#{db_data_type}_value'" do
          expect(select.value_column).to eq :"#{db_data_type}_value"
        end
      end
=end

    end # context: datatype = ?
  end # ConcreteFieldDataType's each


=begin DO NOT DELETE: THIS IS STILL PENDING TO MAKE IT PASS OR REVIEW IF NEEDED
  describe '#saved_values' do
    it 'returns an ActiveRecord::Relation' do
      expect(select.saved_values).to be_a ActiveRecord::Relation
    end
    
    context 'there were values added for this and also other selects' do
      before do
        select.concrete_field.update_column(:db_data_type, 'integer')
        %w[4 8 15].each do |value|
          select.add_value(value: value, input_method: :check)
        end
        
        other_select = FactoryGirl.build(:select, count: select.count)
        other_select.concrete_field.update_column(:db_data_type, 'integer')
        %w[16 23 42].each do |value|
          other_select.add_value(value: value, input_method: :check)
        end
      end
      it 'filters by values belonging to the specific select' do
        array = select.saved_values.values_array
        expect(array).to match_array [4,8,15]
      end
    end
    
    context "when 'count' is nil" do
      it 'returns nil' do
        select.count = nil
        expect(select.saved_values).to be_nil
      end
    end
  end #saved_values

  describe '#summary' do
    context 'when few values are added' do
      let(:result) do
        'House of the Rising Sun, Raised by Another and Solitary'
      end

      before do
        values = ['Solitary', 'Raised by Another', 'House of the Rising Sun']
        values.each do |value|
          select.add_value value: value, input_method: :check
        end
      end
      
      it 'returns a string with all the values sorted alphabetically' do
        expect(select.summary).to eq result
      end

      context 'when repeated values are added' do
        it 'returns each value only once' do
          select.add_value value: 'Solitary', input_method: :lookup
          expect(select.summary).to eq result
        end
      end    
    end

    context 'when many values are added' do
      it 'returns a string that is the first 200 characters' do
        select.concrete_field.update_column(:db_data_type, 'integer')     
        values_list = ''
        200.times do |i|
          select.add_value value: i.to_s, input_method: :check
          values_list += "#{i}, "
        end
        expect(select.summary).to eq values_list[0...200]
      end
    end    
  end #summary

  describe '#range' do
    before do
      select.concrete_field.min = 0
      select.concrete_field.max = 10
      select.save! # for setting 'from' and 'to' defaults
    end

    context "when both selects' range values have been changed" do

      before { select.from = 3; select.to = 5 }
      let(:range_values) { {from:3, to:5} }

      it 'should return a hash with the new values' do
        expect(select.range).to eq range_values
      end
    end 

    context "when only 1 of the selects' range values has been changed" do
      [:from, :to].each do |limit|
        context "when only '#{limit.upcase}' is defined" do
          before { select.__send__("#{limit}=".to_sym, 2); select.save }

          let(:range_values) do
            hash = {from: 0, to: 10}
            hash[limit] = 2
            hash
          end

          it 'returns the hash with only 1 value modified' do
            expect(select.range).to eq range_values
          end
        end
      end
    end

    context "when the selects' range values have not been changed" do
      let(:range_values) { {from: 0, to: 10} }

      it 'returns its default values' do
        expect(select.range).to eq range_values
      end
    end
  end

  describe '#query_gen' do

    before do
      select.concrete_field.db_data_type = 'integer'
      select.concrete_field.stub(:select_query_header).and_return(header)
      select.concrete_field.stub(:select_blanks_condition)
        .and_return(blanks_condition)
    end
    
    let(:header) { 'HEADER' }
    let(:blanks_condition) { 'BLANKS_CONDITION' }

    let(:first_condition) do
      count_id = select.count_id
      "`process_test`.`count#{count_id}_values`"
    end

    let(:values_column) do
      db_data_type = select.concrete_field.db_data_type
      "#{first_condition}.#{db_data_type}_value"
    end

    let(:values_condition) { "#{first_condition}.select_id = #{select.id}" }

    let(:inner_condition) do
      str = select.concrete_field.select_query_values_condition
      str % [first_condition, values_column, values_column, values_condition]
    end

    context 'when it receives a temp_table' do
      it 'forwards the temp_table to ConcreteField#select_query_header' do
        temp_table = 'TEMP_TABLE'
        expect(select.concrete_field).to(receive(:select_query_header)
          .with(temp_table).once)
        select.save! # so the from and to values are assigned
        select.query_gen(temp_table) 
      end
    end

    context "when it doesn't receive a temp_table" do
      it 'calls ConcreteField#select_query_header with no arguments' do
        expect(select.concrete_field).to(receive(:select_query_header)
          .with(nil).once)
        select.save! # so the from and to values are assigned
        select.query_gen
      end
    end

    select_conditions = '[has_values, has_ranges, has_blank_criterion]'
    
    context "when only one of the conditions is true: #{select_conditions}" do
      context 'when there are only selects with values' do
        before do
          select.add_value value: '2', input_method: :check
        end

        it 'returns the query with values condition' do
          sql_template = <<-END_SQL.strip_heredoc
            <%= header %>
            <%= inner_condition %>
          END_SQL

          sql = ERB.new(sql_template).result(binding)
          expectation = sql.gsub(/\s+/,'')
          clean_query = select.query_gen.gsub(/\s+/,'')
          expect(clean_query).to eq expectation
        end
      end

      context 'when there are only ranges' do
        include_context 'has a range'

        it 'returns the query with range condition' do
          sql_template = <<-END_SQL.strip_heredoc
            <%= header %>
            FILTER_RANGE_SQL
          END_SQL

          sql = ERB.new(sql_template).result(binding)
          expectation = sql.gsub(/\s+/,'')
          clean_query = select.query_gen.gsub(/\s+/,'')
          expect(clean_query).to eq expectation
        end
      end

      %w(blanks non_blanks).each do |criterion|
        context "when it only allows #{criterion}" do
          before { select.blanks = criterion }

          it 'returns the query with blanks conditions' do
            sql_template = <<-END_SQL.strip_heredoc
              <%= header %>
              BLANKS_CONDITION
            END_SQL

            sql = ERB.new(sql_template).result(binding)
            expectation = sql.gsub(/\s+/,'')
            clean_query = select.query_gen.gsub(/\s+/,'')
            expect(clean_query).to eq expectation
          end
        end #only allows
      end
    end

    select_conditions_with_blanks = '[has_values, has_ranges, blank = "blanks"]'
    context "when 2 or more of these #{select_conditions_with_blanks} = true" do
      context 'when there are both values and ranges' do
        include_context 'has a range'
        before { select.add_value value: '2', input_method: :check }

        it 'returns the query with both conditions' do
          sql_template = <<-END_SQL.strip_heredoc
            (
              <%= header %>
              <%= inner_condition %>
            )
            UNION
            (
              <%= header %>
              FILTER_RANGE_SQL
            )
          END_SQL

          sql = ERB.new(sql_template).result(binding)
          expectation = sql.gsub(/\s+/,'')
          clean_query = select.query_gen.gsub(/\s+/,'')
          expect(clean_query).to eq expectation
        end
      end

      context 'when there are values, ranges and blanks criterion = "blanks"' do
        include_context 'has a range'

        before do
          select.add_value value: '2', input_method: :check
          select.blanks = 'blanks'
        end

        it 'returns the query with both conditions' do
          sql_template = <<-END_SQL.strip_heredoc
            (
              <%= header %>
              <%= inner_condition %>
            )
            UNION
            (
              <%= header %>
              FILTER_RANGE_SQL
            )
            UNION
            (
              <%= header %>
              BLANKS_CONDITION
            )
          END_SQL

          sql = ERB.new(sql_template).result(binding)
          expectation = sql.gsub(/\s+/,'')
          clean_query = select.query_gen.gsub(/\s+/,'')
          expect(clean_query).to eq expectation
        end
      end
    end
  end

  describe "#fast_query_gen" do

    before do
      select.concrete_field.db_data_type = 'integer'
      select.concrete_field.stub(:fast_select_query_header).and_return(header)
      select.concrete_field.stub(:select_blanks_condition)
        .and_return(blanks_condition)
      # select.concrete_field.stub(:fast_batch_sql).and_return(batch_condition)
    end
    
    let(:header) { 'HEADER' }
    let(:blanks_condition) { 'BLANKS_CONDITION' }
    # let(:batch_condition) { 'BATCH_CONDITION' }

    let(:first_condition) do
      count_id = select.count_id
      "`process_test`.`count#{count_id}_values`"
    end

    let(:values_column) do
      db_data_type = select.concrete_field.db_data_type
      "#{first_condition}.#{db_data_type}_value"
    end

    let(:values_condition) { "#{first_condition}.select_id = #{select.id}" }

    let(:inner_condition) do
      str = select.concrete_field.select_query_values_condition
      str % [first_condition, values_column, values_column, values_condition]
    end

    select_conditions = '[has_values, has_ranges, has_blank_criterion]'
    
    context "when only one of the conditions is true: #{select_conditions}" do
      context 'when there are only selects with values' do
        before do
          select.add_value value: '2', input_method: :check
        end

        it 'returns the query with values condition' do
          sql_template = <<-END_SQL.strip_heredoc
            <%= header %>
            <%= inner_condition %>
          END_SQL

          sql = ERB.new(sql_template).result(binding)
          expectation = sql.gsub(/\s+/,'')
          clean_query = select.fast_query_gen.gsub(/\s+/,'')
          expect(clean_query).to eq expectation
        end
      end

      context 'when there are only ranges' do
        include_context 'has a range'

        it 'returns the query with range condition' do
          sql_template = <<-END_SQL.strip_heredoc
            <%= header %>
            FILTER_RANGE_SQL
          END_SQL

          sql = ERB.new(sql_template).result(binding)
          expectation = sql.gsub(/\s+/,'')
          clean_query = select.fast_query_gen.gsub(/\s+/,'')
          expect(clean_query).to eq expectation
        end
      end

      %w(blanks non_blanks).each do |criterion|
        context "when it only allows #{criterion}" do
          before { select.blanks = criterion }

          it 'returns the query with blanks conditions' do
            sql_template = <<-END_SQL.strip_heredoc
              <%= header %>
              BLANKS_CONDITION
            END_SQL

            sql = ERB.new(sql_template).result(binding)
            expectation = sql.gsub(/\s+/,'')
            clean_query = select.fast_query_gen.gsub(/\s+/,'')
            expect(clean_query).to eq expectation
          end
        end #only allows
      end
    end

    select_conditions_with_blanks = '[has_values, has_ranges, blank = "blanks"]'
    context "when 2 or more of these #{select_conditions_with_blanks} = true" do
      context 'when there are both values and ranges' do
        include_context 'has a range'
        before { select.add_value value: '2', input_method: :check }

        it 'returns the query with both conditions' do
          sql_template = <<-END_SQL.strip_heredoc
            (
              <%= header %>
              <%= inner_condition %>
            )
            UNION
            (
              <%= header %>
              FILTER_RANGE_SQL
            )
          END_SQL

          sql = ERB.new(sql_template).result(binding)
          expectation = sql.gsub(/\s+/,'')
          clean_query = select.fast_query_gen.gsub(/\s+/,'')
          expect(clean_query).to eq expectation
        end
      end

      context 'when there are values, ranges and blanks criterion = "blanks"' do
        include_context 'has a range'

        before do
          select.add_value value: '2', input_method: :check
          select.blanks = 'blanks'
        end

        it 'returns the query with both conditions' do
          sql_template = <<-END_SQL.strip_heredoc
            (
              <%= header %>
              <%= inner_condition %>
            )
            UNION
            (
              <%= header %>
              FILTER_RANGE_SQL
            )
            UNION
            (
              <%= header %>
              BLANKS_CONDITION
            )
          END_SQL

          sql = ERB.new(sql_template).result(binding)
          expectation = sql.gsub(/\s+/,'')
          clean_query = select.fast_query_gen.gsub(/\s+/,'')
          expect(clean_query).to eq expectation
        end
      end
    end

  end

  %w(max min).each do |type|
    describe "#fast_calc_query_gen" do
      before do
        select.stub(:generic_fast_query_gen)
          .and_return('INNER SQL')
        
        select.concrete_field.stub(:fast_calc_select_query_header).with(type)
          .and_return("SELECT #{type.upcase}(ID) FROM ( %s )")
      end

      let(:header) { select.concrete_field.fast_calc_select_query_header(type) }
      let(:sql) { select.send(:generic_fast_query_gen, '') }

      it "return a query for calculatig the #{type}" do
        sql_template = <<-END_SQL.strip_heredoc
          <%= header % sql %>
        END_SQL

        full_sql = ERB.new(sql_template).result(binding)
        expectation = full_sql.gsub(/\s+/,'')
        clean_query = select.fast_calc_query_gen(type).gsub(/\s+/,'')

        expect(clean_query).to eq expectation
      end

    end
  end

  describe '#reset_range' do
    before do
      select.concrete_field.min = 0
      select.concrete_field.max = 10
      select.from = 3
      select.to = 8
      select.save! # for setting default to and from
    end

    let(:select_with_reset_range) { {from: 0, to: 10} }

    it 'sets the select range to its default values' do
      select.reset_range
      expect(select.range).to eq select_with_reset_range
    end
  end

  describe '#reset_blanks' do
    [true, false].each do |current_criterion|
      context "when has_blank_criterion? = #{current_criterion}" do
          before { select.blanks = 'blanks' if current_criterion }
        it 'resets the criterion' do
          expect(select.reset_blanks).to be_nil
        end
      end
    end
  end

  describe '#has_values?' do
    [true, false].each do |values_present|
      context "when selects has_values = #{values_present}" do
        before do
          select.add_value value: 'a', input_method: 'check' if values_present
        end

        it "returns #{values_present}" do
          expect(select.has_values?).to eq values_present
        end
      end
    end
  end

  describe '#has_ranges?' do
    [true, false].each do |ranges_present|
      context "when selects has_ranges = #{ranges_present}" do
        include_context 'has a range' if ranges_present

        it "returns #{ranges_present}" do
          expect(select.has_ranges?).to eq ranges_present
        end
      end
    end
  end
  
  describe '#has_blank_criterion?' do
    ['blanks', 'non_blanks'].each do |condition|
      context "when blanks is #{condition}" do
        before { select.blanks = condition }

        it 'returns true' do
          expect(select.has_blank_criterion?).to be_true
        end
      end
    end

    context 'when blanks is nil' do
      it 'returns false' do
        expect(select.has_blank_criterion?).to be_false
      end
    end
  end

  describe '#is_active?' do
   context 'when there are no values, no ranges and no blank criterion' do
    it 'returns false' do
      expect(select.is_active?).to be false
    end
   end

   context 'when the are values' do
    before { select.add_value value: 'a', input_method: 'check' }

    it 'returns true' do
      expect(select.is_active?).to be true
    end
   end

   context 'when there are values, ranges and blank criterion' do
    include_context 'has a range'

    before do
      select.add_value value: 'a', input_method: 'check'
      select.blanks = 'blanks'
    end

    it 'returns true' do
      expect(select.is_active?).to be true
    end

   end 
  end

  describe '#default_lookup_class' do
    pending
  end

  describe "#select_bitmap_values" do
    context 'when ui_data_type == bitmap' do
      before { select.concrete_field.ui_data_type = 'bitmap'}
      
      context 'when the are values' do
        before do
          select.add_value value: 'f', input_method: 'check'
          select.add_value value: 'o', input_method: 'check'
          select.add_value value: 'u', input_method: 'check'
          select.add_value value: 'r', input_method: 'check'
        end

        let(:expectation) { [1,2,3,4] }

        it 'returns an array with the selected value ids' do
          pending "A count test table is needed"
          expect(select.select_bitmap_values).to eq expectation
        end
      end

      context 'when there are no values' do
        it 'returs nil' do
          expect(select.select_bitmap_values).to be_nil
        end
      end
    end

    context 'when ui_data_type != bitmap' do
      before { select.concrete_field.ui_data_type = 'binary' }
      it 'returns nil' do
        expect(select.select_bitmap_values).to be_nil
      end
    end
  end
=end


end
