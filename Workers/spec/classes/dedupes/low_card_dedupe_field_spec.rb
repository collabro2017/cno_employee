require_relative '../../spec_helper.rb'

# TO-DO: include these 2 into the specs_helper
require_relative '../../../lib/redis_operations.rb'
require_relative '../../../lib/db_operations.rb'
require_relative '../../../lib/extensions/core_extensions.rb'

describe Classes::LowCardDedupeField do
  using CoreExtensions

  include_context 'a payload header hash is defined'
  include_context 'different field hashes are defined'
  include_context 'padding is defined and configured'

  subject(:low_card_dedupe_field) do
    Classes::LowCardDedupeField.new(
      dedupe_struct, header_hash.to_struct
    )
  end

  let(:header_struct) { header_hash.to_struct }
  let(:dedupe_struct) { bitmap_field_struct  }
  let(:bitmap_field_struct) { bitmap_field_hash.to_struct }

  # Methods
  describe '::new' do
    let(:value_locus_keys) do
      keys = []
      while low_card_dedupe_field.move_to_next_value_id do
        keys <<  low_card_dedupe_field.current_value_locus
      end
      keys
    end

    specify "values enumerator is initialized correctly" do
      locus = dedupe_struct.distinct_count.times.collect do |value|
                "f001_v#{(value + 1).pad(padding)}"
              end

      expect(locus).to eq value_locus_keys
    end
  end


end
