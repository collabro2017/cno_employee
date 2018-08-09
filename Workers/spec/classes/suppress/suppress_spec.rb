require_relative '../../spec_helper.rb'
require_relative 'suppress_dummy'

describe Classes::Suppress do
  using CoreExtensions

  include_context 'a payload header hash is defined'
  include_context 'padding is defined and configured'
  include_context 'redis is mocked'

  # Defaults
  let(:header_struct) { header_hash.to_struct }
  let(:simple_count_result_key) { 'some_key:scr' }
  let(:suppress_result_key) do
    field_id = suppress_struct.criteria[:field_id].pad(padding)
    "#{suppress_base_info}:f#{field_id}:hcsr"
  end

  let(:suppress_objects) do
    Classes::Suppress.build(
      suppress_structs, header_struct, type
    )
  end

  let(:suppress_structs) do
    [file_suppress_struct, order_suppress_struct]
  end

  let(:dummy_suppress) do
    SuppressDummy.new(suppress_struct, header_struct, type)
  end

  let(:type) { 'order' }
  let(:suppress_struct) { order_suppress_struct }
  let(:order_suppress_struct) { order_suppress_hash.to_struct }
  let(:file_suppress_struct) { file_suppress_hash.to_struct }
  
  let(:order_suppress_hash) do
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

  let(:file_suppress_hash) do
    {
      id: 1,
      user_email: 'user@email.com',
      name: 'file1.txt',
      criteria: {
        field_id:   10,
        field_name: 'some_field',
        source_fields: ['field1','field2']
      },
      suppress?: true
    }
  end

  let(:suppress_base_info) { "order#{suppress_struct.id}" }


  before do
    allow(Classes::PreviousOrderSuppress).to(
      receive(:new).and_return(dummy_suppress)
    )

    allow(Classes::FileSuppress).to(
      receive(:new).and_return(dummy_suppress)
    )

    allow(dummy_suppress).to receive(:generate_and_set_suppression_key)
  end

  shared_examples 'it calls substract with the correct key' do
    it 'calls substract with the correct key' do
      expect(RedisOperations).to(
        receive(:subtract).with(
          simple_count_result_key, suppress_result_key, header_struct.total_records
        )
      )
      invoke
    end

    it 'deletes the result_key' do
      expect(RedisOperations).to(
        receive(:del).with(suppress_result_key)
      )
      invoke
    end
  end

  # Methods
  describe '::build' do
    before do
      allow(Classes::Suppress).to(
        receive(:new).and_return(dummy_suppress, dummy_suppress)
      )
    end

    it 'builds a list of Suppress objects' do
      expect(suppress_objects).to eql [dummy_suppress, dummy_suppress]
    end
  end

  describe '::run' do
    let(:invoke) { dummy_suppress.run(simple_count_result_key) }

    context "when suppress is 'order' type" do
      it_behaves_like 'it calls substract with the correct key'
    end

    context "when suppress is 'file' type" do
      let(:suppress_struct) { file_suppress_struct }
      let(:type) { 'file' }

      it_behaves_like 'it calls substract with the correct key'
    end
  end

  describe '#suppress_result_key' do
    it "return the correct key" do
      
      expect(dummy_suppress.suppress_result_key).to(
        eq suppress_result_key
      )
    end
  end # suppress_result_key

end

