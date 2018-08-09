require_relative '../../spec_helper.rb'
require_relative 'breakdown_field_dummy'
require_relative '../shared_contexts'

require_relative '../../../lib/redis_operations.rb'
require_relative '../../../lib/extensions/core_extensions.rb'

describe Classes::Breakdown do
  using CoreExtensions

  include_context 'a payload header hash is defined'
  include_context 'different field hashes are defined'
  include_context 'padding is defined and configured'

  # Defaults
  subject(:breakdown) { breakdown1 }

  let(:header_struct) { header_hash.merge(max_rows: max_rows).to_struct }
  let(:max_rows) { 100 }

  let(:count_result_key) { 'some_key:scr' }

  # Breakdown1
  let(:breakdown1) do
    Classes::Breakdown.new(
      breakdown_struct1, header_struct, nil, count_result_key
    )
  end
  let(:breakdown_struct1) { bitmap_field_hash.to_struct }

  # Breakdown2
  let(:breakdown2) do
    Classes::Breakdown.new(
      breakdown_struct2, header_struct, breakdown1, count_result_key
    )
  end
  let(:breakdown_struct2) { binary_field_hash.to_struct }

  # Breakdown3
  let(:breakdown3) do
    Classes::Breakdown.new(
      breakdown_struct3, header_struct, breakdown2, count_result_key
    )
  end
  let(:breakdown_struct3) { string_field_hash.to_struct }

  shared_context 'there is a set of breakdowns defined' do
    let(:breakdown_structs) do
      [breakdown_struct1, breakdown_struct2, breakdown_struct3]
    end

    let(:breakdowns) do
      Classes::Breakdown.build(
        breakdown_structs, header_struct, count_result_key
      )
    end

    let(:field1) do
      options = {filter_key: count_result_key}
      BreakdownFieldDummy.new(
        breakdown_struct1, header_struct, options: options
      )
    end

    let(:field2) do
      field1.move_to_next_value_id
      options = {filter_key: field1.current_pbdr_key}
      BreakdownFieldDummy.new(
        breakdown_struct2, header_struct, options: options
      )
    end

    let(:field3) do
      field2.move_to_next_value_id
      options = {filter_key: field2.current_pbdr_key}
      BreakdownFieldDummy.new(
        breakdown_struct3, header_struct, options: options
      )
    end

    # Stub the initializer, #field and low-card fields' current_value_key
    before do
      allow(Classes::Breakdown).to(
        receive(:new).and_return(breakdown1, breakdown2, breakdown3)
      )

      allow(breakdown1).to receive(:field).and_return(field1)
      allow(breakdown2).to receive(:field).and_return(field2)
      allow(breakdown3).to receive(:field).and_return(field3)

      allow(field1).to receive(:current_value_key).and_return('f1_vX:lcfbs')
      allow(field2).to receive(:current_value_key).and_return('f2_vX:lcfbs')
      allow(field3).to receive(:current_value_key).and_return('f3_vX:lcfbs')
    end
  end

  # Methods
  describe '::build' do
    include_context 'there is a set of breakdowns defined'

    it 'returns a Breakdown object' do
      expect(breakdowns).to be_a(Classes::Breakdown)
    end

    it 'returns the LAST Breakdown object' do
      expect(breakdowns).to eq(breakdown3)
    end

    it 'builds a linked list of Breakdown objects' do
      current = breakdowns # retrieve the last one
      [breakdown3, breakdown2, breakdown1].each do |breakdown|
        expect(current).to eq breakdown
        current = current.previous
      end
    end
  end

  describe 'Enumerable behavior - #each method implementation' do
    let(:breakdown) { breakdowns }
    let(:expected_rows) do
      arr = []
      (1..breakdown_struct1.distinct_count).each do |bd1_value_id|
        (1..breakdown_struct2.distinct_count).each do |bd2_value_id|
          (1..breakdown_struct3.distinct_count).each do |bd3_value_id|
            arr << [bd1_value_id, bd2_value_id, bd3_value_id, 0]
          end
        end
      end
      arr
    end

    include_context 'there is a set of breakdowns defined'
    
    it 'returns a [String, Array] tuple' do
      breakdown.each do |key, row|
        expect([key, row].map(&:class)).to eq [String, Array]
      end
    end

    it 'returns the right rows' do
      expect(breakdown.entries.map(&:last)).to eq expected_rows
    end

    context 'when the max_rows is below the total rows' do
      let(:max_rows) { 20 }

      context 'when reaches count_total' do
        it 'stops when reaches the max_rows value' do
          expect(breakdown.entries.size).to eq max_rows
        end
      end

      context "when haven't reached count_total" do
        let(:count_total) { 10 }
        let(:sum) { 0 }

        before do
          allow(breakdown).to receive(:count_total).and_return(count_total)
        end

        it 'returns one more row' do
          expect(breakdown.entries.size).to eq max_rows + 1
        end

        specify 'the last row has nils and the difference' do
          expect(breakdown.entries.last).to(
            eq [nil, [nil, nil, nil, count_total - sum]]
          )
        end
      end
    end

    context 'when the max_rows is below the total rows' do
    end
  end # each

  describe '#get_next_key' do
    let(:breakdown) { breakdowns }
    let(:invoke) { breakdown.get_next_key }

    include_context 'there is a set of breakdowns defined'

    context 'when its field is nil' do
      let(:field3) { nil }
      it('returns_nil') { expect(invoke).to be_nil }
    end

    context 'when its field still has value_ids' do
      let(:expected) { '<some expected key>' }
      it "returns its field's current_pbdr_key" do
        allow(field3).to receive(:current_pbdr_key).and_return(expected)
        expect(invoke).to eq expected
      end
    end

    context 'when it does NOT have any more value_ids' do
      before do
        breakdown_struct3.distinct_count.times do
          field3.move_to_next_value_id
        end
      end

      shared_examples 'it returns nil' do
        it 'returns nil' do
          expect(invoke).to be_nil
        end
      end

      context "when it has a 'previous'" do
        context "when the previous still has value_ids" do
          it 'returns the value_id of previous moved' do
            expect(invoke).to match /f002_v002-f003_v001\)/
          end
        end

        context 'when the previous does NOT have any more value_ids' do
          before do
            breakdown_struct1.distinct_count.times do
              field1.move_to_next_value_id
            end

            breakdown_struct2.distinct_count.times do
              field2.move_to_next_value_id
            end
          end

          it_behaves_like 'it returns nil'
        end
      end

      context "when it does NOT have a 'previous'" do 
        before do
          allow(breakdown).to receive(:previous).and_return(nil)
        end
       
        it_behaves_like 'it returns nil' 
      end
    end
  end #get_next_key

  describe 'private method #field' do
    let(:invoke) { breakdown.send(:field) }
    let(:breakdown_struct) { breakdown_struct1 }

    %w[binary bitmap].each do |type|
      context "when the field has ui_data_type = '#{type}'" do
        before { breakdown_struct[:ui_data_type] = type }
        it 'initializes an instance of LowCardBreakdownField' do
          expect(Classes::LowCardBreakdownField).to receive(:new)
          invoke
        end
      end
    end

    %w[string integer date].each do |type|
      context "when the field has ui_data_type = '#{type}'" do
        before do
          breakdown_struct[:ui_data_type] = type
        end
        
        it 'initializes an instance of HighCardBreakdownField' do
          expect(Classes::HighCardBreakdownField).to receive(:new)
          invoke
        end
      end
    end

    context 'when the field has an unrecognized ui_data_type' do
      let(:unrecognized) { 'whatever' }
      before { breakdown_struct1[:ui_data_type] = "#{unrecognized}" }
      it "raises an StandardError" do
        expect{ invoke }.to raise_error(StandardError, /#{unrecognized}/)
      end
    end

    context "when does NOT have a 'previous'" do
      before do
        allow(breakdown).to receive(:previous).and_return(nil)
      end 

      specify "the 'filter_key' passed is the 'count_result_key'" do
        options = {filter_key: count_result_key}
        expect(Classes::LowCardBreakdownField).to(
          receive(:new).with(
            breakdown_struct, header_struct, options: options
          )
        )
        invoke
      end
    end

    context "when it has a 'previous'" do
      let(:breakdown) { breakdown2 }
      let(:breakdown_struct) { breakdown_struct2 }
      let(:next_key_of_previous) { '<next_key_of_previous>' }

      include_context 'there is a set of breakdowns defined'

      before do
        allow(breakdown1).to(
          receive(:get_next_key).and_return(next_key_of_previous)
        )

        # Unstub #field for breakdown1
        allow(breakdown).to receive(:field).and_call_original
      end

      context "when the previous' next_key is NOT nil" do
        specify "the 'filter_key' passed is the next_key of previous" do
          options = {filter_key: next_key_of_previous}
          expect(Classes::LowCardBreakdownField).to(
            receive(:new).with(
              breakdown_struct, header_struct, options: options
            )
          )
          invoke
        end
      end

      context "when the previous' next_key is nil" do
        let(:next_key_of_previous) { nil }
        it('returns nil') { expect(invoke).to be_nil }
      end
    end
  end #field

end

