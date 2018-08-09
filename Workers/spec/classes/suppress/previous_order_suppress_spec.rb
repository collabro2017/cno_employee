require_relative '../../spec_helper'
require_relative '../shared_contexts'

describe Classes::PreviousOrderSuppress do
  using CoreExtensions

  include_context 'a payload header hash is defined'
  include_context 'padding is defined and configured'

  subject(:previous_order_suppress) do
    Classes::PreviousOrderSuppress.new(suppress_struct, header_struct)
  end

  let(:suppress_hash) do
    {
      id: 1,
      datasource: 'test_datasource',
      record_key: {
        field_id:   10,
        field_name: 'key_field'
      },
      suppress?: true
    }
  end

  let(:header_struct) { header_hash.to_struct }
  let(:suppress_struct) { suppress_hash.to_struct }

  let(:suppress_base_info) { "order#{suppress_struct.id}" }

  before do
    allow(DbOperations).to receive(:get_suppress_value_ids_as_bit_string)
    allow(DbOperations).to receive(:get_suppress_record_ids_as_bit_string)
    allow(RedisOperations).to receive(:set)
    allow(ToNodesDelegator).to receive_message_chain(:new, :enqueue)
  end

  # Methods
  describe 'generate_and_set_suppression_key' do
    let(:invoke) { previous_order_suppress.generate_and_set_suppression_key }

    context "when count and order have the same Datasource" do
      it 'generates the bit string' do
        expect(DbOperations).to(
          receive(:get_suppress_record_ids_as_bit_string).once
        )

        invoke
      end

      it 'sets the key in Redis' do
        expect(RedisOperations).to receive(:set).once

        invoke
      end
    end

    context "when the count and the order have different Datasources" do
      before do
        suppress_hash[:datasource] = 'test_datasource2'
      end

      it "retrieves the ids of the count's datasource" do
        expect(ToNodesDelegator.new).to receive(:enqueue).once

        invoke
      end
    end
  end #generate_suppression_key

end
