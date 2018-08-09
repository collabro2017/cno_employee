require_relative '../spec_helper'
require_relative 'shared_contexts'

# TO-DO: include this into the specs_helper
require_relative '../../lib/redis_operations.rb'
require_relative '../../lib/to_nodes_delegator.rb'
require_relative '../../lib/extensions/core_extensions.rb'

describe Classes::Field do
  using CoreExtensions

  include_context 'a payload header hash is defined'
  include_context 'padding is defined and configured'
  include_context 'different field hashes are defined'

  subject(:field) do
    Classes::Field.new(field_struct)
  end

  # Payload field info
  let(:field_struct) { bitmap_field_hash.to_struct }

  let(:options) { {filter_key: '<some key>'} }

  # Methods
  describe '#current_value_locus' do
    context 'when @current_value has NOT been set' do
      it 'raises an ArgumentError' do
        expect { field.current_value_locus }.to raise_error(ArgumentError)
      end
    end
    
    context 'when @current_value has been set' do
      before { field.move_to_next_value_id }
      it 'returns a String with information on how to get to the value' do
        padded_field_id = field_struct[:field_id].pad(padding)
        padded_value_id = 1.pad(padding)
        expected = "f#{padded_field_id}_v#{padded_value_id}"
        
        expect(field.current_value_locus).to eq expected
      end
    end

  end #full_current_value_locus

  describe '#move_to_next_value_id' do
    context 'when there still are value_ids available' do
      it 'returns true' do
        expect(field.move_to_next_value_id).to eq true
      end

      it 'updates the current_value_id' do
        field.move_to_next_value_id
        expect(field.current_value_locus).to match(/v#{1.pad(padding)}/)
      end
    end

    context 'when there are no more value_ids available' do
      it 'returns nil' do
        field_struct[:distinct_count].times { field.move_to_next_value_id }
        expect(field.move_to_next_value_id).to eq false
      end
    end
  end #next_value_id
end

