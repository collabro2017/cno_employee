require_relative '../../spec_helper.rb'
require_relative 'dedupe_field_dummy.rb'

require_relative '../../../lib/redis_operations.rb'
require_relative '../../../lib/db_operations.rb'
require_relative '../../../lib/extensions/core_extensions.rb'

describe Classes::Dedupe do
  using CoreExtensions

  include_context 'a payload header hash is defined'
  include_context 'different field hashes are defined'
  include_context 'padding is defined and configured'

  # Defaults
  let(:header_struct) { header_hash.to_struct }
  let(:simple_count_result_key) { 'some_key:scr' }
  let(:field_result_key) { 'some_key:hcfr' }
  let(:deduped_count_result_key) { 'some_key:dcr' }

  subject(:dedupe) do
    Classes::Dedupe.new(dedupe_struct, header_struct, simple_count_result_key)
  end
  let(:dedupe_struct) { bitmap_field_hash.to_struct }

  shared_context 'there is a dedupe defined' do
    let(:field1) do
      DedupeFieldDummy.new(dedupe_struct, header_struct)
    end

    # Stub the initializer, #field and low-card fields' current_value_key
    before do
      allow(dedupe).to receive(:field).and_return(field1)

      allow(field1).to receive(:current_value_key).and_return('f1:lcfbs')
      allow(dedupe).to(
        receive(:deduped_count_result_key).and_return(deduped_count_result_key)
      )
    end
  end


  # Methods
  describe '::run' do
    let(:invoke) { dedupe.run }
    include_context 'there is a dedupe defined'

    context 'when field is LowCard' do
      before do
        allow(field1).to receive(:is_a?).and_return(true)
        allow(RedisOperations).to receive(:first_on_bit).and_return(1)
      end

      it "calls intersect the correct amount of times" do
        expect(RedisOperations).to(
          receive(:intersect).exactly(dedupe_struct.distinct_count).times
        )
        invoke
      end

      context 'when NO bit is on' do
        before do
          allow(RedisOperations).to receive(:first_on_bit).and_return(nil)
        end

        it 'DO NOT call unite' do
          expect(RedisOperations).not_to receive(:unite)

          invoke
        end
      end

      context 'when ANY bit is on' do
        before do
          allow(RedisOperations).to receive(:first_on_bit).and_return(1)
        end

        it 'calls turn_bit_on' do
          expect(RedisOperations).to(
            receive(:turn_bit_on).with(any_args).at_least(:once)
          )

          invoke
        end

        it 'calls unite with the correct key' do
          expect(RedisOperations).to(
            receive(:unite).with(
              deduped_count_result_key,any_args
            ).at_least(:once)
          )

          invoke
        end
      end
      
    end

    context 'when field is HighCard' do
      before do
        allow(field1).to receive(:is_a?).and_return(false)
        allow(field1).to receive(:field_result_key).and_return(field_result_key)
      end

      it 'calls unite with the correct key' do
        expect(RedisOperations).to(
          receive(:unite).with(
            deduped_count_result_key,field_result_key
          ).exactly(1).times
        )

        invoke
      end

      it 'deletes the result_key' do
        expect(RedisOperations).to receive(:del).with(field_result_key)

        invoke
      end
    end
  end

end

