require 'active_support/core_ext/integer/inflections'
require_relative '../../lib/extensions/binary_string'


def sample_string
  # "RB"
  BinaryString.new([0b01010010, 0b01000010].pack('C*'))
end

def on_positions
  ret = []
  bits = sample_string.unpack('B*').first.chars.map(&:to_i)
  bits.each_with_index { |bit, i| ret << i if bit == 1 }
  ret
end

def iterations_for(batch_size)
  base_iterations = on_positions.size / batch_size
  divisible = (on_positions.size % batch_size == 0)
  divisible ? base_iterations : base_iterations + 1
end

#-------------------------------------------------------------------------------


describe BinaryString do
  
  subject(:binary_string) do
    sample_string
  end

  describe '::build' do
    it 'builds a N sized BinaryString' do
      #pending 'aasfdasasdfasd'
    end
  end

  describe '#set_bit' do

    let(:binary_string) do
      BinaryString.new([0b00000000, 0b00000000].pack('C*'))
    end

    {
      0  => [0b10000000, 0b00000000].pack('C*'),
      1  => [0b01000000, 0b00000000].pack('C*'),
      2  => [0b00100000, 0b00000000].pack('C*'),
      3  => [0b00010000, 0b00000000].pack('C*'),
      4  => [0b00001000, 0b00000000].pack('C*'),
      5  => [0b00000100, 0b00000000].pack('C*'),
      6  => [0b00000010, 0b00000000].pack('C*'),
      7  => [0b00000001, 0b00000000].pack('C*'),
      8  => [0b00000000, 0b10000000].pack('C*'),
      9  => [0b00000000, 0b01000000].pack('C*'),
      10 => [0b00000000, 0b00100000].pack('C*'),
      11 => [0b00000000, 0b00010000].pack('C*'),
      12 => [0b00000000, 0b00001000].pack('C*'),
      13 => [0b00000000, 0b00000100].pack('C*'),
      14 => [0b00000000, 0b00000010].pack('C*'),
      15 => [0b00000000, 0b00000001].pack('C*')
    }.each do |position, expected_value|
      context "when setting the #{position.ordinalize} bit" do
        it 'sets the right bit' do
          binary_string.set_bit(position)
          expect(binary_string).to eq expected_value
        end
      end
    end
  end #set_bit

  describe '#positions_by_batch' do
    context 'when the batch size is 0' do
      it 'iterates 0 times' do
        iterations = 0
        binary_string.positions_by_batch(0) do |batch|
          iterations += 1
        end
        expect(iterations).to eq 0
      end
    end

    context 'when the batch size is larger than the total on bits' do
      it 'iterates one time' do
        iterations = 0
        binary_string.positions_by_batch(on_positions.size + 1) do |batch|
          iterations += 1
        end
        expect(iterations).to eq 1
      end

      it 'returns all positions in the single iteration' do
        result = nil
        binary_string.positions_by_batch(on_positions.size + 1) do |batch|
          result = batch
        end
        expect(result).to eq on_positions
      end 
    end
 
    context 'when the batch size is lesser or equal than the total on bits' do
      (1..on_positions.size).each do |batch_size|
        it "iterates #{iterations_for(batch_size)} time(s)" do
          iterations = 0
          binary_string.positions_by_batch(batch_size) do |batch|
            iterations += 1
          end
          expect(iterations).to eq iterations_for(batch_size)
        end

        it "returns batches with #{batch_size} position(s)" do
          binary_string.positions_by_batch(batch_size) do |batch|
            expect(batch.size).to be <= batch_size
          end
        end

        specify 'the union of all batches equals the expected on positions' do
          on_bits = []
          binary_string.positions_by_batch(batch_size) do |batch|
            on_bits += batch
          end
          expect(on_bits).to eq on_positions
        end

      end
    end # context: batch size < total on bits
  end #positions_by_batch

end
