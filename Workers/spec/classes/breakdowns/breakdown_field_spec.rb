require_relative '../../spec_helper'
require_relative 'breakdown_field_dummy'
require_relative '../shared_contexts'

# TO-DO: include these 2 into the specs_helper
require_relative '../../../lib/redis_operations.rb'
require_relative '../../../lib/extensions/core_extensions.rb'

describe Classes::BreakdownField do
  using CoreExtensions

  include_context 'a payload header hash is defined'
  include_context 'different field hashes are defined'

  let(:breakdown_field) do
     BreakdownFieldDummy.new(breakdown_struct, header_struct, options: options)
  end

  let(:options) { {filter_key: filter_key} }
  let(:header_struct) { header_hash.to_struct }
  let(:breakdown_struct) { bitmap_field_hash.to_struct  }

  let(:values) { (1..breakdown_struct.distinct_count).each }
  let(:filter_key) { "#{prefix}#{some_pairs}#{suffix}" }
  let(:some_pairs) { "f00X_v015-f00Y_v023" }

  let(:job_id) { '16' }
  let(:prefix) do
    "#{Classes::BreakdownField::NAMESPACE}:j#{job_id}:("
  end
  let(:suffix) { Classes::BreakdownField::PBDR_KEY_SUFFIX }

  before do # Mock methods
    allow(breakdown_field).to receive(:job_id).and_return(job_id)
  end

  describe '::extract_value_ids_from_pbdr_key' do
    let(:invoke) do
      Classes::BreakdownField::extract_value_ids_from_pbdr_key(filter_key)
    end

    context 'when key is in the correct form' do
      it 'returns the value_ids present in the key' do
        expect(invoke).to eq [15, 23]
      end
    end

    context 'when key does not have any vXXX component' do
      let(:filter_key) { 'whatever string it is' }
      it('returns nil') { expect(invoke).to be_nil }
    end
  end # ::extract_value_ids_from_pbdr_key

  describe '#reset_filter_key' do
    let(:invoke) do
      breakdown_field.reset_filter_key('<some prefix>:(<some pairs>):pbdr')
    end

    it 'removes the old keys from Redis' do
      (1..4).each do |value_id|
        key = /#{value_id}#{Regexp.escape(suffix)}\z/
        expect(RedisOperations).to(receive(:del).with(key))
      end
      invoke
    end
    
    it 'calls #initialize_values_enumerator' do
      expect(breakdown_field).to receive(:initialize_values_enumerator).once
      invoke
    end
  end #reset_filter_key

  describe '#current_pbdr_key' do
    let(:invoke) { breakdown_field.current_pbdr_key }
    let(:locus) { breakdown_field.current_value_locus }

    context 'when the current value_id is nil' do
      it('returns nil') { expect(invoke).to be_nil }
    end

    context 'when the current value_id is assigned' do
      before { breakdown_field.move_to_next_value_id }

      context "when the filter_key ends in ':pbdr'" do
        it 'has the right prefix and suffix' do
          expect(invoke).to(
            match(/\A#{Regexp.escape(prefix)}.+#{Regexp.escape(suffix)}\z/)
          )
        end

        it 'starts like the filter_key without its suffix' do
          expect(invoke).to(
            match(/\A#{Regexp.escape(filter_key.sub(suffix,''))}/)
          )
        end

        it "contains the current_value_locus before the suffix" do
          escaped_suffix = Regexp.escape(suffix)
          expect(invoke).to match /#{locus}#{escaped_suffix}\z/
        end
      end

      %w[:scr :dcr].each do |cr_suffix|
        context "when the filter_key ends in '#{cr_suffix}'" do
          let(:filter_key) { "<some key>#{cr_suffix}" }

          it "contains ONLY ONE field_id / value_id pair" do
            expect(invoke).to eq "#{prefix}#{locus}#{suffix}"
          end
        end
      end
    end # the current value_id is assigned
  end #current_pbdr_key

  describe '#current_pbdr_row' do
    let(:invoke) { breakdown_field.current_pbdr_row }

    context 'when the current value_id is nil' do
      it('returns nil') { expect(invoke).to be_nil }
    end

    context 'when the current value_id is assigned' do
      let(:total) { 4816162342 }

      before do
        breakdown_field.move_to_next_value_id

        allow(RedisOperations).to(
          receive(:bitcount).with(
            breakdown_field.current_pbdr_key
          ).and_return(total)
        )
      end

      it 'contains the total on bits of the current_pbdr_key' do
        expect(invoke).to include(total)
      end

      context "when the filter_key ends in ':pbdr'" do
        it 'contains ALL the value_ids present in the filter key' do
          expect([15, 23] - invoke).to be_empty
        end
      end

      %w[:scr :dcr].each do |cr_suffix|
        context "when the filter_key ends in '#{cr_suffix}'" do
          let(:filter_key) { "<some key>#{cr_suffix}" }

          it "ONLY contains the field's current value_id and the total" do
            id = Classes::BreakdownField::extract_value_ids_from_pbdr_key(
                   breakdown_field.current_value_locus
                 )
            expect(invoke).to eq [*id, total]
          end
        end
      end
    end # the current value_id is assigned
  end #current_pbdr_row

end

