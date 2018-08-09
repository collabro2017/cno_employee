require_relative '../../spec_helper'
require_relative '../shared_contexts'

# TO-DO: include these 2 into the specs_helper
require_relative '../../../lib/redis_operations.rb'
require_relative '../../../lib/extensions/core_extensions.rb'

describe Classes::LowCardBreakdownField do
  using CoreExtensions

  include_context 'a payload header hash is defined'
  include_context 'different field hashes are defined'
  include_context 'padding is defined and configured'

  subject(:low_card_breakdown_field) do
    Classes::LowCardBreakdownField.new(
      breakdown_struct, header_hash.to_struct, options: options
    )
  end

  let(:options) { {filter_key: ':scr'} }
  let(:header_struct) { header_hash.to_struct }
  let(:breakdown_struct) { bitmap_field_struct  }
  let(:bitmap_field_struct) { bitmap_field_hash.to_struct }

  before do
    # Fake the existance of all value keys so it doesn't try to load them
    (1..breakdown_struct.distinct_count).each do |value_id|
      allow(RedisOperations).to(
        receive(:exists).with(/#{value_id}:lcfbs/).and_return(true)
      )
    end
  end

  # Methods
  describe '::new' do
    describe 'initialization of the value_ids enumerator' do
      it "calls 'intersect' with each value_id and the filter_key" do
        (1..breakdown_struct.distinct_count).each do |value_id|
          expect(RedisOperations).to(
            receive(:intersect).with(
              anything, /#{value_id}:lcfbs/, options[:filter_key]
            )
          )
        end

        low_card_breakdown_field
      end

      describe "the pbdr keys where the intersection results are saved" do
        let(:prefix) do
          namespace = Classes::LowCardBreakdownField::NAMESPACE
          "#{namespace}:j#{header_struct.job_id}:("
        end

        let(:suffix) { '):pbdr' }

        after { low_card_breakdown_field }

        context "when the filter_key ends in ':pbdr'" do
          let(:options) { {filter_key: "#{prefix}:(<some pairs>):pbdr"} }
          
          it 'has the right prefix and suffix' do
            expect(RedisOperations).to(
              receive(:intersect).with(
                /\A#{Regexp.escape(prefix)}.+#{Regexp.escape(suffix)}\z/,
                any_args
              )
            ).at_least(:once)
          end

          it 'starts like the filter_key without its suffix' do
            suffixless_filter_key = options[:filter_key].sub(suffix,'')

            expect(RedisOperations).to(
              receive(:intersect).with(
                /\A#{Regexp.escape(suffixless_filter_key)}/, any_args
              ).at_least(:once)
            )
          end

          it "contains the field's value locus before the suffix" do
            field_id = breakdown_struct.field_id.pad(padding)

            (1..breakdown_struct.distinct_count).each do |value_id|
              padded_value_id = value_id.pad(padding)
              expect(RedisOperations).to(
                receive(:intersect).with(
                  /f#{field_id}_v#{padded_value_id}#{Regexp.escape(suffix)}\z/,
                  any_args
                )
              )
            end
          end
        end

        context "when the filter_key ends in ':scr' or ':dcr'" do
          it "contains ONLY ONE field_id / value_id pair" do
            field_id = breakdown_struct.field_id.pad(padding)

            (1..breakdown_struct.distinct_count).each do |value_id|
              pair = "f#{field_id}_v#{value_id.pad(padding)}"

              expect(RedisOperations).to(
                receive(:intersect).with("#{prefix}#{pair}#{suffix}", any_args)
              )
            end
          end
        end
      end # the pbdr keys

      describe 'the resulting values Enumerator' do
        let(:value_locus_keys) do
          keys = []
          while low_card_breakdown_field.move_to_next_value_id do
            keys <<  low_card_breakdown_field.current_value_locus
          end
          keys
        end

        context "when NONE of the field's values return records" do
          before do
            allow(RedisOperations).to receive(:bitcount).and_return(0)
          end

          specify 'values is empty' do
            expect(value_locus_keys.count).to be 0
          end

          specify 'all keys are removed' do
            expect(RedisOperations).to(
              receive(:del).exactly(breakdown_struct.distinct_count).times
            )
            low_card_breakdown_field
          end
        end

        context "when exactly ONE of the field's values returns records" do
          cardinality = 4 # bitmap's distinct count
          positions = (1..cardinality) 

          positions.each do |i|
            context "when it is the ##{i}" do
              before do
                bitcounts = positions.map { |pos| pos == i ? 1 : 0 }
                allow(RedisOperations).to(
                  receive(:bitcount).and_return(*bitcounts)
                )
              end

              specify 'values only has 1 item' do
                expect(value_locus_keys.count).to be 1
              end

              specify "values' first (unique) item is #{i}" do
                expect("f001_v#{i.pad(padding)}").to(
                  eq value_locus_keys.first
                )
              end

              specify 'all keys are removed but one' do
                expect(RedisOperations).to(
                  receive(:del).exactly(cardinality - 1).times
                )
                low_card_breakdown_field
              end
            end
          end
        end

        context "when MORE THAN ONE of the field's values return records" do
          let(:bitcounts) { [4, 8, 0, 16] }
          let(:relevant_positions) do
            bitcounts.map.with_index { |v, i| (i + 1) if v != 0 }.compact
          end

          before do
            allow(RedisOperations).to(
              receive(:bitcount).and_return(*bitcounts)
            )
          end

          specify "values matches the positions that don't return 0" do
            locus = relevant_positions.map do |pos|
                      "f001_v#{pos.pad(padding)}"
                    end

            expect(locus).to eq value_locus_keys

          end

          specify 'keys that return 0 are removed' do
            zero_ones = bitcounts.size - relevant_positions.size
            expect(RedisOperations).to receive(:del).exactly(zero_ones).times
            low_card_breakdown_field
          end
        end

        context "when ALL the field's values return records" do
          before do
            allow(RedisOperations).to receive(:bitcount).and_return(1)
          end

          specify "values Array's size matches the field's distinct count" do
            expect(value_locus_keys.count).to eq breakdown_struct.distinct_count
          end

          specify 'NO keys are removed' do
            expect(RedisOperations).not_to receive(:del)
            low_card_breakdown_field
          end
        end
      end # resulting values Enumerator

    end # initialize_values_enumerator behavior
  end # ::new

end
