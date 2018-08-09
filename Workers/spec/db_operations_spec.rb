require 'active_support/core_ext/string/strip'

require_relative '../lib/db_operations'
require_relative '../lib/decorated_payload'

describe DbOperations do

  subject(:klass) { DbOperations }

  let(:payload) do
    DecoratedPayload.instance
  end

  describe '::selected_value_ids' do
    pending
  end

  describe '::save_selected_value_ids_to_file' do
    pending
  end

  describe '::load_selected_value_ids_from_file' do
    pending
  end

  describe '::drop_selected_values_ids_table' do
    pending
  end

  describe '::selected_record_ids_as_bit_string' do
    pending
  end

  describe '::create_breakdown_record_ids_table' do
    pending
  end

  describe '::node_drop_breakdown_record_ids_table' do
    pending
  end

  describe '::load_breakdown_record_ids_table_from_file' do
    pending
  end

  describe '::insert_breakdown_record_ids' do
    pending
  end

  describe '::save_breakdown_record_ids_table_to_file' do
    pending
  end

  describe '::breakdown_record_ids_by_value_id' do
    pending
  end

  describe '::drop_and_create_breakdown_results_table' do
    pending
  end

  describe '::insert_breakdown_results' do
    pending
  end

  describe '::create_order_record_ids_table' do
    pending
  end

  describe '::drop_order_record_ids_table' do
    pending
  end

  describe '::insert_order_record_ids_table' do
    pending
  end

  describe '::extract_order_records' do
    pending
  end

  describe '::order_formatted_value_column' do
    pending
  end

  describe '::breakdown_formatted_value_column' do
    pending
  end

  describe '::drop_table' do
    pending
  end

  describe '::drop_view' do
    pending
  end

  describe '::create_table'
    pending
  end

  describe '::create_view'
    pending
  end

  describe '::save_query_result_to_file' do
    pending
  end

  describe '::save_table_to_file' do
    pending
  end

end

