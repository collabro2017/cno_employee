require_relative '../../spec_helper.rb'
require_relative 'select_field_dummy'

# TO-DO: include these 2 into the specs_helper
require_relative '../../../lib/redis_operations.rb'
require_relative '../../../lib/extensions/core_extensions.rb'

describe Classes::SelectField do
  using CoreExtensions

  include_context 'a select payload header hash is defined'
  include_context 'different select field hashes are defined'

  let(:select_field) do
     SelectFieldDummy.new(select_struct, header_struct)
  end

  let(:namespace) { 'sway' }

  let(:header_struct) { header_hash.to_struct }
  let(:select_struct) { bitmap_field_hash.to_struct  }


  #Methods
  describe '#full_field_locus' do
    let(:invoke) do
      select_field.full_field_locus
    end

    specify 'returns the correct full_value_locus' do
      expect(invoke).to eq "#{header_struct.datasource}_f001"
    end
  end #full_field_locus

  describe '#full_field_locus_values' do
    let(:invoke) do
      select_field.full_field_locus_values
    end

    specify 'returns the correct full_field_locus_values' do
      expect(invoke).to eq "#{header_struct.datasource}_f001_values"
    end
  end #full_field_locus_values

  describe '#linked_count_result_key' do
    let(:invoke) do
      select_field.linked_count_result_key
    end

    specify 'returns the correct linked_count_result_key' do
      expect(invoke).to eq "#{namespace}:j#{header_struct.job_id}:lcr"
    end
  end #linked_count_result_key

  describe '#field_values_table_name' do
    let(:invoke) do
      select_field.field_values_table_name
    end

    specify 'returns the correct field_values_table_name' do
      expect(invoke).to eq "count#{header_struct.count_id}_values"
    end
  end #field_values_table_name

  describe '#field_values_column_name' do
    let(:invoke) do
      select_field.field_values_column_name
    end

    specify 'returns the correct field_values_column_name' do
      expect(invoke).to eq "#{select_struct.db_data_type}_value"
    end
  end #field_values_column_name

  shared_examples 'it returns the correct criteria' do
    let(:invoke) do
      select_field.criteria
    end

    it 'returns the correct criteria' do
      expect(invoke).to eq expected_criteria
    end
  end

  describe '#criteria' do
    context 'when no criterion is matched' do
      let(:bitmap_field_hash) do
        {
          select_id:      1,
          field_id:       1,
          ui_data_type:   'bitmap',
          db_data_type:   'integer',
          distinct_count: 4,
          has_values?:    false,
          has_ranges?:    false,
          has_blanks_criterion?: false,
          exclude?: false,
          has_files?: false,
          linked_to_next?: false
        }
      end

      let(:expected_criteria) { [] }
      it_behaves_like 'it returns the correct criteria'
    end

    context 'when any criterion is matched' do
      let(:bitmap_field_hash) do
        {
          select_id:      1,
          field_id:       1,
          ui_data_type:   'bitmap',
          db_data_type:   'integer',
          distinct_count: 4,
          has_values?:    true,
          has_ranges?:    false,
          has_blanks_criterion?: true,
          exclude?: false,
          has_files?: false,
          linked_to_next?: false
        }
      end

      let(:expected_criteria) { [:values, :blanks_criterion] }
      it_behaves_like 'it returns the correct criteria'
    end

    context 'when ALL criterions are matched' do
      let(:bitmap_field_hash) do
        {
          select_id:      1,
          field_id:       1,
          ui_data_type:   'bitmap',
          db_data_type:   'integer',
          distinct_count: 4,
          has_values?:    true,
          has_ranges?:    true,
          has_blanks_criterion?: true,
          exclude?: false,
          has_files?: true,
          linked_to_next?: false
        }
      end

      let(:expected_criteria) { [:values, :ranges, :blanks_criterion, :files] }
      it_behaves_like 'it returns the correct criteria'
    end
  end #criteria
end