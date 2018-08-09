require_relative '../../spec_helper'

# TO-DO: include these 2 into the specs_helper
require_relative '../../../lib/redis_operations.rb'
require_relative '../../../lib/db_operations.rb'
require_relative '../../../lib/extensions/core_extensions.rb'

describe Classes::LowCardSelectField do
  using CoreExtensions

  include_context 'a select payload header hash is defined'
  include_context 'different select field hashes are defined'
  include_context 'padding is defined and configured'

  subject(:low_card_select_field) do
    Classes::LowCardSelectField.new(
      select_struct, header_hash.to_struct
    )
  end

  let(:header_struct) { header_hash.to_struct }
  let(:select_struct) { bitmap_field_struct  }
  let(:bitmap_field_struct) { bitmap_field_hash.to_struct }

  let(:selected_value_ids) { [1,2,3] }

  before do
    allow(DbOperations).to(
      receive(:get_selected_value_ids).and_return(selected_value_ids)
    )
  end

  # Methods
  describe '::new' do
    let(:value_locus_keys) do
      keys = []
      while low_card_select_field.move_to_next_value_id do
        keys <<  low_card_select_field.current_value_locus
      end
      keys
    end

    before do
      allow(DbOperations).to(
        receive(:get_selected_value_ids).and_return(selected_value_ids)
      )
    end

    specify "calls get_selected_value_ids" do
      expect(DbOperations).to receive(:get_selected_value_ids).exactly(1).times
      low_card_select_field
    end

    specify "values enumerator is nitialized correctly" do
      locus = selected_value_ids.map do |pos|
                "f001_v#{pos.pad(padding)}"
              end

      expect(locus).to eq value_locus_keys
    end
  end


end
