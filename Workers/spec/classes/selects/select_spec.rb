require_relative '../../spec_helper.rb'

require_relative '../../../lib/redis_operations.rb'
require_relative '../../../lib/db_operations.rb'
require_relative '../../../lib/extensions/core_extensions.rb'

describe Classes::Select do
  using CoreExtensions

  include_context 'a select payload header hash is defined'
  include_context 'different select field hashes are defined'
  include_context 'padding is defined and configured'
  include_context 'redis is mocked'

  # Defaults
  let(:header_struct) { header_hash.to_struct }
  let(:simple_count_result_key) { 'some_key:scr' }
  let(:field_result_key) { 'some_key:hcfr' }
  let(:linked_count_result_key) { 'some_key:lcr' }

  subject(:select) do
    Classes::Select.new(select_struct1, header_struct, simple_count_result_key)
  end
  let(:select_struct1) { bitmap_field_hash.to_struct }

  shared_context 'there is a select defined' do
    let(:field1) do
      SelectFieldDummy.new(select_struct1, header_struct)
    end

    # Stub the initializer, #field and low-card fields' current_value_key
    before do
      allow(select).to receive(:field).and_return(field1)

      allow(field1).to receive(:current_value_key).and_return('f1:lcfbs')
    end
  end


  # Methods
  describe '::run' do
    let(:invoke) { select.run }
    include_context 'there is a select defined'

    context 'when field is LowCard' do
      before do
        allow(field1).to receive(:is_a?).and_return(true)
        allow(field1).to(
          receive(:linked_count_result_key).and_return(linked_count_result_key)
        )
      end

      context 'when NONE of the values are selected' do
        before do
          allow(field1).to receive(:move_to_next_value_id).and_return(false)
        end

        it "DOESN'T call unite" do
          expect(RedisOperations).not_to receive(:unite)
          invoke
        end
      end

      context 'when SOME of the values are selected' do
        it "Calls unite the correct amount of times" do
          expect(RedisOperations).to(
            receive(:unite).exactly(select_struct1.distinct_count).times
          )
          invoke
        end
      end

      it 'calls union_if_group with the correct key' do
        expect(select).to(
          receive(:union_if_group).with(any_args).exactly(1).times
        )
        invoke
      end
    end

    context 'when field is HighCard' do
      before do
        allow(field1).to receive(:is_a?).and_return(false)
        allow(field1).to receive(:field_result_key).and_return(field_result_key)
      end

      it "DOESN'T call unite" do
        expect(RedisOperations).not_to receive(:unite)
        invoke
      end

      it 'calls union_if_group with the correct key' do
        expect(select).to(
          receive(:union_if_group).with(
            field_result_key
          ).exactly(1).times
        )
        invoke
      end

      it 'deletes the result_key' do
        expect(RedisOperations).to(
          receive(:del).with(field_result_key)
        )
        invoke
      end
    end
  end

end

