require_relative '../../spec_helper'
require_relative '../shared_contexts'

# TO-DO: include these 2 into the specs_helper
require_relative '../../../lib/redis_operations.rb'
require_relative '../../../lib/to_nodes_delegator.rb'
require_relative '../../../lib/extensions/core_extensions.rb'

describe Classes::HighCardDedupeField do
  using CoreExtensions

  include_context 'a payload header hash is defined'
  include_context 'different field hashes are defined'
  include_context 'padding is defined and configured'

  subject(:high_card_dedupe_field) do
    Classes::HighCardDedupeField.new(
      dedupe_struct, header_struct, options: options
    )
  end

  let(:options) { {filter_key: ':scr'} }

  let(:header_struct) { header_hash.to_struct }

  let(:dedupe_struct) { string_field_struct  }
  let(:string_field_struct) { string_field_hash.to_struct }

  let(:job_key_prefix) { 'sway:j42' }

  before do
    allow(ToNodesDelegator).to receive_message_chain(:new, :enqueue)
    allow(ToNodesDelegator).to(
      receive_message_chain(:new, :sub_jobs).and_return([])
    )
  end

  # Methods
  describe '::new' do
    it "calls 'ToNodesDelegator' once" do
      expect(ToNodesDelegator.new).to receive(:enqueue).once

      high_card_dedupe_field
    end
  end # ::new

  describe '#field_result_key' do
    it "return the correct key" do
      expect(high_card_dedupe_field.field_result_key).to(
        eq "#{job_key_prefix}:f#{dedupe_struct.field_id.pad(padding)}:hcdr"
      )
    end
  end # ::new

end
