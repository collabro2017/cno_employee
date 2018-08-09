require_relative '../../spec_helper'
require_relative '../shared_contexts'

# TO-DO: include these 2 into the specs_helper
require_relative '../../../lib/redis_operations.rb'
require_relative '../../../lib/to_nodes_delegator.rb'
require_relative '../../../lib/extensions/core_extensions.rb'

describe Classes::HighCardBreakdownField do
  using CoreExtensions

  include_context 'a payload header hash is defined'
  include_context 'different field hashes are defined'
  include_context 'padding is defined and configured'

  subject(:high_card_breakdown_field) do
    Classes::HighCardBreakdownField.new(
      breakdown_struct, header_struct, options: options
    )
  end

  let(:options) { {filter_key: ':scr'} }

  let(:header_struct) { header_hash.merge(max_rows: max_rows).to_struct }
  let(:max_rows) { breakdown_struct.distinct_count + 1 }

  let(:breakdown_struct) { string_field_struct  }
  let(:string_field_struct) { string_field_hash.to_struct }

  before do
    # Fake the existance of all value keys so it doesn't try to load them
    allow(ToNodesDelegator).to receive_message_chain(:new, :enqueue)

    value_ids = (1..breakdown_struct.distinct_count).map do |value_id|
                  "v#{value_id.pad(padding)}"
                end
    allow(RedisOperations).to receive(:list).and_return(value_ids)
  end

  # Methods
  describe '::new' do
    describe 'initialization of the value_ids enumerator' do
      context 'when amount of keys already set < max_rows' do
        it "calls 'ToNodesDelegator' at least once" do
          expect(ToNodesDelegator.new).to receive(:enqueue).at_least(:once)

          high_card_breakdown_field
        end
      end

      context 'when amount of keys already set >= max_rows' do
        let(:max_rows) { breakdown_struct.distinct_count }
        it "calls 'ToNodesDelegator' at least once" do
          expect(ToNodesDelegator.new).not_to receive(:enqueue)

          high_card_breakdown_field
        end
      end

      describe "the pbdr keys where the intersection results are saved" do
        let(:prefix) do
          namespace = Classes::HighCardBreakdownField::NAMESPACE
          "#{namespace}:j#{header_struct.job_id}:("
        end

        let(:suffix) { '):pbdr' }

        let(:escaped_prefix) { Regexp.escape(prefix) }
        let(:escaped_suffix) { Regexp.escape(suffix) }

        after { high_card_breakdown_field }

        context "when the filter_key ends in ':pbdr'" do
          let(:options) { {filter_key: "#{prefix}:(<some pairs>):pbdr"} }
          
          it 'has the right prefix and suffix' do
            regexp = /\A#{escaped_prefix}.+#{escaped_suffix}\z/
            expect(ToNodesDelegator.new).to(
              receive(:enqueue).with(
                hash_including(options: hash_including(key_wildcard: regexp))
              ).at_least(:once)
            )
          end

          it 'starts like the filter_key without its suffix' do
            suffixless_filter_key = options[:filter_key].sub(suffix,'')
            regexp = /\A#{Regexp.escape(suffixless_filter_key)}/

            expect(ToNodesDelegator.new).to(
              receive(:enqueue).with(
                hash_including(options: hash_including(key_wildcard: regexp))
              ).at_least(:once)
            )
          end

          it "contains the field's value locus wildcard before the suffix" do
            field_id = breakdown_struct.field_id.pad(padding)
            regexp = /f#{field_id}_v\*#{escaped_suffix}\z/

            expect(ToNodesDelegator.new).to(
              receive(:enqueue).with(
                hash_including(options: hash_including(key_wildcard: regexp))
              ).at_least(:once)
            )
          end
        end

        context "when the filter_key ends in ':scr' or ':dcr'" do
          it "contains ONLY ONE field_id / value_id pair" do
            field_id = breakdown_struct.field_id.pad(padding)

            regexp = /#{escaped_prefix}f#{field_id}_v\*#{escaped_suffix}\z/

            expect(ToNodesDelegator.new).to(
              receive(:enqueue).with(
                hash_including(options: hash_including(key_wildcard: regexp))
              ).at_least(:once)
            )
          end
        end
      end # the pbdr keys

      describe 'the resulting values Enumerator' do
        let(:value_locus_keys) do
          keys = []
          while high_card_breakdown_field.move_to_next_value_id do
            keys << high_card_breakdown_field.current_value_locus
          end
          keys
        end

        context "when NONE of the field's values return records" do
          before do
            allow(RedisOperations).to receive(:list).and_return([])
          end

          specify 'values is empty' do
            expect(value_locus_keys.count).to be 0
          end
        end

        context "when exactly ONE of the field's values returns records" do
          cardinality = 10 # string's distinct count
          positions = (1..cardinality)

          positions.each do |i|
            context "when it is the ##{i}" do
              before do
                allow(RedisOperations).to(
                  receive(:list).and_return(["v#{i.pad(padding)}"])
                )
              end

              specify 'values only has 1 item' do
                expect(value_locus_keys.count).to be 1
              end

              specify "values' first (unique) item is #{i}" do
                expect(value_locus_keys.first).to eq "f003_v#{i.pad(padding)}"
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
            ret = relevant_positions.map { |pos| "v#{pos.pad(padding)}" }

            allow(RedisOperations).to(receive(:list).and_return(ret.shuffle))
          end

          specify "values matches the positions that don't return 0" do
            locus = relevant_positions.map do |pos|
                      "f003_v#{pos.pad(padding)}"
                    end

            expect(value_locus_keys).to eq locus
          end
        end

        context "when ALL the field's values return records" do
          before do
            ret = (1..breakdown_struct.distinct_count).map do |pos|
                    "v#{pos.pad(padding)}"
                  end
            allow(RedisOperations).to(
              receive(:list).and_return(ret)
            )
          end

          specify "values Array's size matches the field's distinct count" do
            expect(value_locus_keys.count).to eq breakdown_struct.distinct_count
          end
        end
      end # resulting values Enumerator

    end # initialize_values_enumerator behavior
  end # ::new

end
