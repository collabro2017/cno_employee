require_relative '../../spec_helper'

# TO-DO: include these 2 into the specs_helper
require_relative '../../../lib/redis_operations.rb'
require_relative '../../../lib/to_nodes_delegator.rb'
require_relative '../../../lib/extensions/core_extensions.rb'

describe Classes::HighCardSelectField do
  using CoreExtensions

  include_context 'a select payload header hash is defined'
  include_context 'different select field hashes are defined'
  include_context 'padding is defined and configured'

  subject(:high_card_select_field) do
    Classes::HighCardSelectField.new(
      select_struct, header_struct, options: options
    )
  end

  let(:options) { {simple_count_result_key: ':scr'} }

  let(:header_struct) { header_hash.to_struct }

  let(:select_struct) { string_field_struct  }
  let(:string_field_struct) { string_field_hash.to_struct }

  before do
    # Fake the existance of all value keys so it doesn't try to load them
    allow(ToNodesDelegator).to receive_message_chain(:new, :enqueue)
  end

  # Methods

end
