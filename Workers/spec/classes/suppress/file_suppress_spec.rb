require_relative '../../spec_helper'
require_relative '../shared_contexts'

require 'active_support/core_ext/string/strip'

describe Classes::FileSuppress, fakefs: true do
  using CoreExtensions

  include_context 'a payload header hash is defined'
  include_context 'padding is defined and configured'

  subject(:file_suppress) do
    Classes::FileSuppress.new(suppress_struct, header_struct)
  end

  let(:file_content) do
    <<-END_CONTENT.strip_heredoc
      #{file_header.join(',')}
      1,2,3,4,5
      a,b,c,d,e
      A,B,C,D,E
      v,w,x,y,z
      V,W,X,Y,Z
    END_CONTENT
  end

  let(:file_content_no_header) do
    <<-END_CONTENT.strip_heredoc
      1,2,3,4,5
      a,b,c,d,e
      A,B,C,D,E
      v,w,x,y,z
      V,W,X,Y,Z
    END_CONTENT
  end

  let(:source_fields_content) do
    [
      {'field1' => '2', 'field2' => '3', 'field4' => "5\n"},
      {'field1' => 'b', 'field2' => 'c', 'field4' => "e\n"},
      {'field1' => 'B', 'field2' => 'C', 'field4' => "E\n"},
      {'field1' => 'w', 'field2' => 'x', 'field4' => "z\n"},
      {'field1' => 'W', 'field2' => 'X', 'field4' => "Z\n"}
    ]
  end

  let(:file_name) { 'file1.txt' }
  let(:output_path) { '/output-data' }
  let(:local_file_path) { "#{output_path}/#{file_name}" }
  let(:file_header) { ['field0','field1','field2','field3','field4'] }

  let(:source_fields) { ['field1','field2','field4'] }
  let(:suppress_hash) do
    {
      id: 1,
      user_email: 'user@email.com',
      name: file_name,
      criteria: {
        field_id:   10,
        field_name: 'some_field',
        source_fields: source_fields
      },
      suppress?: true
    }
  end

  let(:header_struct) { header_hash.to_struct }
  let(:suppress_struct) { suppress_hash.to_struct }

  let(:load_table_name) { "suppress_file#{suppress_struct.id}_xxxxuuid" }

  let(:database_obj) { double(Sequel::Database) }

  before do
    FileUtils.mkdir_p(output_path)
    File.write(local_file_path, file_content)

    allow(DatabaseConnection).to receive(:[]).and_return(database_obj)
    allow(database_obj).to receive(:run)

    allow(DbOperations).to receive(:drop_table)
    allow(DbOperations).to receive(:create_table)
    allow(DbOperations).to receive(:rename_table)
    allow(DbOperations).to receive(:table_exists?).and_return(false)

    allow(RB::Hasher).to receive(:generate).and_return('0000000000')

    allow(FileTransfer).to receive(:get_header_from_s3).and_return(file_header)
    allow(FileTransfer).to receive(:download_from_s3).and_return(local_file_path)

    allow(SecureRandom).to receive(:uuid).and_return('xxxxuuid')

    allow(DbOperations).to receive(:get_suppress_value_ids_as_bit_string)
    allow(RedisOperations).to receive(:set)
    allow(ToNodesDelegator).to receive_message_chain(:new, :enqueue)
  end

  shared_examples 'it generates and insert keys' do
    it 'generate the keys' do
      source_fields_content.each do |values|
        expect(RB::Hasher).to receive(:generate).with(values)
      end

      invoke
    end

    it 'insert the keys' do
      expected_sql = <<-END_SQL.strip_heredoc
                      INSERT INTO "process"."#{load_table_name}"
                        ("#{suppress_struct.criteria[:field_name]}")
                      VALUES
                        (0000000000)
                    END_SQL

      records = source_fields_content.count

      expect(database_obj).to(
        receive(:run).with(expected_sql).exactly(records).times
      )

      invoke
    end
  end

  # Methods
  describe '#generate_and_set_suppression_key' do
    let(:invoke) { file_suppress.generate_and_set_suppression_key }

    describe 'file preparation' do
      it 'reads the file header' do
        expect(FileTransfer).to receive(:get_header_from_s3)

        invoke
      end

      it 'downloads the file' do
        expect(FileTransfer).to receive(:download_from_s3)

        invoke
      end

      it 'prepare the tables' do
        expect(DbOperations).to receive(:drop_table)
        expect(DbOperations).to receive(:create_table)

        invoke
      end
    end

    describe 'file loading' do
      context 'when the file extension is NOT .zip' do
        before do
          allow(File).to(
            receive(:readlines).and_return(StringIO.new(file_content))
          )
        end

        it 'reads the file' do
          expect(File).to receive(:readlines).with(local_file_path)

          invoke
        end

        it_behaves_like 'it generates and insert keys'
      end

      context 'when the file extension is .zip' do
        let(:file_name) { 'file1.zip' }

        before do
          allow(IO).to(
            receive(:popen).and_return(StringIO.new(file_content_no_header))
          )
        end

        it 'unzip the file' do
          expect(IO).to(
            receive(:popen).with("unzip -p #{local_file_path} | tail -n +2")
          )

          invoke
        end

        it_behaves_like 'it generates and insert keys'
      end

      it 'rename the table' do
        expect(DbOperations).to receive(:rename_table)

        invoke
      end
    end

    describe 'suppress process' do
      it "calls 'ToNodesDelegator' once" do
        expect(ToNodesDelegator.new).to receive(:enqueue).once

        invoke
      end
    end

    describe 'cleanup' do
      it 'drop the file' do
        expect(File).to receive(:delete).with(local_file_path)

        invoke
      end

      it 'drop the tables' do
        expect(DbOperations).to receive(:drop_table)

        invoke
      end
    end
  end # generate_and_set_suppression_key

end
