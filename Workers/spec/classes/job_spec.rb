require_relative '../spec_helper.rb'
require_relative 'dummy_class'

describe Classes::Job do
  using CoreExtensions
  
  let(:dummy_class) do
     DummyClass.new(header_struct)
  end

  include_context 'a select payload header hash is defined'

  let(:namespace) { 'sway' }

  let(:header_struct) { header_hash.to_struct }

  #Methods
  describe '#job_key_prefix' do
    specify 'returns the correct job_key_prefix' do
      expect(dummy_class.job_key_prefix).to(
        eq "#{namespace}:j#{header_struct.job_id}"
      )
    end
  end #job_key_prefix
end