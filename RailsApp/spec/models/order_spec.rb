require 'spec_helper'

describe Order do
  subject(:order) { FactoryGirl.build(:order) }
  
  #--------------------------
  it "has a valid Factory" do
    expect(order).to be_valid
  end
  #--------------------------

  # attributes
  it { is_expected.to respond_to(:is_quick) }

  # associations
  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:count) }
  it { is_expected.to respond_to(:jobs) }
  it { is_expected.to respond_to(:outputs) }

  # enums
  it { is_expected.to respond_to(:cap_type) }

  # delegations
  it { is_expected.to delegate_method(:datasource).to(:count) }

  # columns  
  it { is_expected.to respond_to(:ftp_url) }
  it { is_expected.to respond_to(:s3_url) }
  it { is_expected.to respond_to(:total_cap) }

  # validations
  it { is_expected.to validate_presence_of(:count) }

  # hooks
  describe "setting the initial output layout after create" do
    let(:outputs_cfs) { order.outputs.map(&:concrete_field) }

    let(:default_cfs) { order.datasource.default_output_layout.to_a }
    let(:selects_cfs) { order.count.selects.map(&:concrete_field) }

    before do # create a bunch of concrete fields
      13.times do |i|
        cf = FactoryGirl.build(:concrete_field, datasource: order.datasource)
        cf.position = i
        cf.save!
      end
    end

    shared_context "when 'even' concrete_fields are default_output_layout" do
      before do
        order.datasource.concrete_fields.each do |cf|
          if cf.position.even?
            cf.default_output_layout = (cf.position / 2)
            cf.save!
          end
        end
      end
    end

    shared_context "when 'every 3rd' concrete_field is a select" do
      before do
        order.datasource.concrete_fields.each do |cf|
          if (cf.position % 3).zero? 
            FactoryGirl.create(:select, concrete_field: cf, count: order.count)
          end
        end
      end
    end

    shared_examples 'has initial output layout' do
      specify "the initial output layout is NOT empty" do
        order.save!
        expect(order.outputs).to_not be_empty
      end
    end

    context "when there aren't default layout concrete fields or selects" do
      specify 'the initial output layout is empty' do
        order.save!
        expect(order.outputs).to be_empty
      end
    end

    context "when there are default layout concrete fields" do
      include_context "when 'even' concrete_fields are default_output_layout"

      it_behaves_like 'has initial output layout'

      specify 'the initial output layout matches the default_output_layout' do
        order.save!
        expect(outputs_cfs).to match default_cfs
      end
    end

    context "when there are selects" do
      include_context "when 'every 3rd' concrete_field is a select"

      it_behaves_like 'has initial output layout'

      specify 'the initial output layout matches the selects' do
        order.save!
        expect(outputs_cfs).to match selects_cfs
      end
    end

    context "when there are default layout concrete fields AND selects" do
      include_context "when 'even' concrete_fields are default_output_layout"
      include_context "when 'every 3rd' concrete_field is a select"

      it_behaves_like 'has initial output layout'

      specify 'the default layout concrete fields are part of the layout' do
        order.save!
        expect(outputs_cfs).to include *default_cfs
      end

      specify 'the selects are part of the initial output layout' do
        order.save!
        expect(outputs_cfs).to include *selects_cfs
      end

      specify 'the default output layout concrete fields come first' do
        order.save!
        expect(outputs_cfs.first(default_cfs.size)).to eq default_cfs
      end

      specify 'the layout does not contain repeated items when they overlap' do
        order.save!
        expect(outputs_cfs).to eq default_cfs | selects_cfs
      end
    end
  end # setting the initial output layout

  describe '#reset_cap_type' do
    let(:cap_type) { 'total_cap' }
    before { order.cap_type = cap_type }

    context 'when the method has NOT been invoked' do
      it 'returns the cap_type' do
        expect(order.cap_type).to eq cap_type
      end
    end

    context 'when the method is invoked' do
      it 'returns nil' do
        order.reset_cap_type
        expect(order.cap_type).to be_nil
      end
    end
  end

  describe '#has_cap_type?' do
    CapType.each do |cap_type|
      context "when cap_type is #{cap_type}" do
        before { order.cap_type = cap_type }

        it 'returns true' do
          expect(order.has_cap_type?).to be_truthy
        end
      end
    end

    context 'when cap_type is nil' do
      it 'returns false' do
        expect(order.has_cap_type?).to be_falsey
      end
    end
  end

  describe "#total_cap" do
    shared_examples 'total_cap is the MAX allowed' do
      it 'returns the MAX allowed' do
        expect(order.total_cap).to eq Order::MAX_ORDER_SIZE
      end
    end

    context 'when a total_cap has NOT been defined' do
      it_behaves_like 'total_cap is the MAX allowed'
    end

    context 'when the total_cap exeeds the MAX allowed' do
      before { order.total_cap = Order::MAX_ORDER_SIZE + 1 }
      it_behaves_like 'total_cap is the MAX allowed'
    end

    context 'when the total_cap does NOT exeed the MAX allowed' do
      let(:total_cap) { Order::MAX_ORDER_SIZE - 1 }
      before { order.total_cap = total_cap }

      it 'returns the total_cap that was set' do
        expect(order.total_cap).to eq total_cap
      end
    end
  end

  describe '#outputs_table_names' do
    [true, false].each do |is_keycoded|
      context "when the concrete_field.keycoded? = #{is_keycoded}" do
        before do
          3.times do
            cf = FactoryGirl.create(:concrete_field, 
                                    datasource: order.datasource,
                                    keycoded: (is_keycoded ? true : nil))
            
            out = FactoryGirl.create(:output, order: order, concrete_field: cf)
          end

          order.outputs.each do |output|
            allow(output).to receive(:escaped_caption).and_return('CAPTION')
            allow(output.concrete_field).to(
              receive(:column_table).and_return('COL_TABLE')
            )
          end
        end

        let(:expectation_array) do
          arr = order.outputs.map { |out| 'COL_TABLE_values.value as CAPTION' }
          ret = arr.join(",\n")
        end

        it 'returns an array with the outputs table names' do
          expect(order.outputs_table_names).to eq expectation_array
        end
      end
    end
  end

end

