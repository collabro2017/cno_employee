require_relative '../spec_helper'
require_relative 'shared_contexts'

# TO-DO: include these 2 into the specs_helper
require_relative '../../lib/redis_operations.rb'
require_relative '../../lib/extensions/core_extensions.rb'

describe Classes::LowCardField, fakefs: true do

  using CoreExtensions

  include_context 'a payload header hash is defined'
  include_context 'padding is defined and configured'
  include_context 'different field hashes are defined'
  include_context 'redis is mocked'

  subject(:field) do
    Classes::LowCardField.new(field_struct, header_hash.to_struct)
  end

  # Payload field info
  let(:field_struct) { bitmap_field_struct  }

  let(:bitmap_field_struct) { bitmap_field_hash.to_struct }

  let(:binary_field_struct) { binary_field_hash.to_struct }

  # Redis keys
  let(:key_namespace) { 'sway' }
  let(:key_type) { 'lcfbs' } # Low Cardinality Field Binary String

  let(:current_value_key_string) do
    "#{key_namespace}:#{field_value_locus}:#{key_type}"
  end

  let(:field_value_locus) do
    padded_field_id = field_struct[:field_id].pad(padding)
    padded_value_id = current_value_id.pad(padding)
    "#{datasource}_f#{padded_field_id}_v#{padded_value_id}"
  end

  # Test values
  let(:current_value_id) { 1 }

  let(:values) { bitmap_values }

  let(:bitmap_values) do
    [
      [0b00100100, 0b00_000000],
      [0b00001000, 0b01_000000],
      [0b01010010, 0b00_000000],
      [0b10000001, 0b10_000000],
    ]
  end

  let(:binary_values) do
    [
      [0b01100110, 0b10_000000], # OFF
      [0b10011001, 0b01_000000]  # ON
    ]
  end

  # Configuration
  before do
    allow(Configuration).to(
      receive(:paths).and_return({'bit_strings_dir' => '/'})
    )
  end

  # Set the first value id
  before do
    field.move_to_next_value_id
  end

  # Methods

  describe '#full_current_value_locus' do
    it 'retuns a String with information on how to get to the value' do
      expect(field.full_current_value_locus).to eq field_value_locus
    end
  end #full_current_value_locus

  describe '#current_value_key' do
    let(:invoke) { field.current_value_key }

    before do
      bitmap_values.each_with_index do |value, i|
        File.write("#{datasource}_f001_v00#{i + 1}.bin", value.pack('CC'))
      end

      File.write("#{datasource}_f002_v002.bin", binary_values.last.pack('CC'))
    end

    it 'returns the key of the value that is set' do
      expect(invoke).to eq current_value_key_string
    end

    specify 'the value is already stored at the key returned' do
      expect(redis.get(invoke)).to eq values[current_value_id - 1].pack('CC')
    end

    context 'when field is binary and value is OFF' do
      let(:field_struct) { binary_field_struct }
      let(:values) { binary_values }

      it 'calculates the complement of the ON value to set the OFF value' do
        one, two = [1,2].map { |n| "v#{n.pad(padding)}" }
        on_value_key_string = current_value_key_string.sub(one, two)
        expect(RedisOperations).to(
          receive(:complement).with(
            current_value_key_string, on_value_key_string, total_records
          )
        )
        invoke
      end
    end

    context 'when the key already exists' do
      before do
        allow(RedisOperations).to(
          receive(:exists).with(current_value_key_string)
        ).and_return(true)
      end

      after { invoke }

      it 'does not load a file' do
        expect(File).not_to receive :binread
      end

      it 'does not set a value' do
        expect(RedisOperations).not_to receive :set
      end

      it 'does not calculate a value' do
        expect(RedisOperations).not_to receive :complement
      end  
    end
  end #current_value_key

end
