#================== BREAKDOWNS =======================

shared_context 'a payload header hash is defined' do
  # Payload header info
  let(:header_hash) do 
    {
      datasource: datasource,
      total_records: total_records,
      job_id: job_id
    }
  end

  let(:datasource) { 'test_datasource' }
  let(:total_records) { 10 }
  let(:job_id) { 42 }
end

shared_context 'different field hashes are defined' do
  let(:bitmap_field_hash) do
    {
      field_id:       1,
      ui_data_type:   'bitmap',
      distinct_count: 4,
      conflict_values: []
    }
  end

  let(:binary_field_hash) do
    {
      field_id:       2,
      ui_data_type:   'binary',
      distinct_count: 2,
      conflict_values: []
    }
  end

  let(:string_field_hash) do
    {
      field_id:       3,
      ui_data_type:   'string',
      distinct_count: 10,
      conflict_values: []
    }
  end
end

#================== SELECTS =======================


shared_context 'a select payload header hash is defined' do
  # Payload header info
  let(:header_hash) do 
    {
      count_id:      count_id,
      job_id:        job_id,
      datasource:    datasource,
      total_records: total_records
    }
  end

  let(:datasource) { 'test_datasource' }
  let(:total_records) { 10 }
  let(:job_id) { 42 }
  let(:count_id) { 25 }
end

shared_context 'different select field hashes are defined' do
  let(:bitmap_field_hash) do
    {
      select_id:      1,
      field_id:       1,
      ui_data_type:   'bitmap',
      db_data_type:   'integer',
      distinct_count: 4,
      has_values?:    true,
      has_ranges?:    false,
      has_blanks_criterion?: false,
      exclude?: false,
      has_files?: false,
      linked_to_next?: false
    }
  end

  let(:binary_field_hash) do
    {
      select_id:      2,
      field_id:       2,
      ui_data_type:   'binary',
      db_data_type:   'string',
      distinct_count: 2,
      has_values?:    true,
      has_ranges?:    false,
      has_blanks_criterion?: false,
      exclude?: false,
      has_files?: false,
      linked_to_next?: false
    }
  end

  let(:string_field_hash) do
    {
      select_id:      3,
      field_id:       3,
      ui_data_type:   'string',
      db_data_type:   'string',
      distinct_count: 10,
      has_values?:    true,
      has_ranges?:    false,
      has_blanks_criterion?: false,
      exclude?: false,
      has_files?: false,
      linked_to_next?: false
    }
  end
end

#================== GENERAL =======================

shared_context 'padding is defined and configured' do
  # Configuration
  let(:padding) { 3 }
  let(:total_nodes) { 5 }

  before do
    allow(Configuration).to(
      receive(:numbers).and_return(
        {'padding' => padding, 'total_nodes' => total_nodes}
      )
    )
  end
end

shared_context 'redis is mocked' do
  let(:redis) { Redis.new }

  before do
    allow(RedisOperations).to(receive(:redis).and_return(redis))
  end
end

