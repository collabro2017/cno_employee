require 'spec_helper'

describe ConcreteField do

  subject(:concrete_field) { FactoryGirl.build(:concrete_field) }
  let(:datafile_conn) { concrete_field.datasource.datafile_class.connection }
  
  #--------------------------
	it "has a valid Factory" do
		expect(concrete_field).to be_valid
	end
	#--------------------------

  # associations
  it { is_expected.to respond_to(:datasource) }
  it { is_expected.to respond_to(:field) }
  it { is_expected.to respond_to(:field_category) }
  it { is_expected.to respond_to(:lookup_options) }

  # validations
  it { is_expected.to validate_presence_of(:field) } 
  it 'validates the uniqueness of default_output_layout' do
    expect(subject).to(
      validate_uniqueness_of(:default_output_layout)
        .scoped_to(:datasource_id)
        .allow_nil
    )
  end

  # enum
  it { is_expected.to respond_to(:db_data_type) }
  it { is_expected.to respond_to(:ui_data_type) }

  # columns
  it { is_expected.to respond_to(:breakdown) }
  it { is_expected.to respond_to(:selectable) }
  it { is_expected.to respond_to(:default_output_layout) }
  it { is_expected.to respond_to(:enabled) }
  it { is_expected.to respond_to(:keycoded) }
  it { is_expected.to respond_to(:min) }
  it { is_expected.to respond_to(:max) }
  it { is_expected.to respond_to(:lookup) }

  
  it_behaves_like "sortable", :datasource

  # hooks
  describe "setting default values" do
    context "when a 'field_category' isn't specified" do
      it "gets one assigned by default after initialization" do
        expect(subject.field_category).not_to be_nil
      end

      it "gets one assigned by default before saving" do
        subject.field_category = nil
        subject.save!
        expect(subject.field_category).not_to be_nil
      end
    end
  end

  # methods
  describe "::eager_load_fields" do
    ["field_name", "description"].each do |attr_name|
      specify "the items returned have the additional attribute #{attr_name}" do
        field = FactoryGirl.create(:field, name: "new_field")
        FactoryGirl.create(:concrete_field, field: field)

        concrete_field = ConcreteField.eager_load_fields.first
        
        expect(concrete_field.has_attribute?(attr_name)).to be_truthy
      end
    end
    
    specify "the relation has an INNER JOIN" do
      expect(ConcreteField.eager_load_fields.to_sql).to include("INNER JOIN")
    end
  end

  describe "#name" do
    let(:name) { "field_name" }
    before { subject.field.name = name }

    context "when a custom name is NOT defined"  do
      it "returns the name of its field" do
        expect(subject.name).to eq name
      end
      
      context "when 'field_name' attribute is loaded" do
        before do
          allow(subject).to receive(:read_attribute).and_call_original
          allow(subject).to(
            receive(:read_attribute)
              .with('field_name')
              .and_return('attr_field_name')
          )
        end
        
        it "returns it" do
          expect(subject.name).to eq "attr_field_name"
        end
        
        it "does NOT ask for it to its field" do          
          expect(subject).not_to receive(:field)
          subject.name
        end
      end
      
      context "when 'field_name' attribute is not loaded" do
        it "asks for it to its field" do
          expect(subject).to receive(:field).and_call_original
          subject.name
        end
      end
      
    end
    
    context "when a custom name is defined" do
      before { subject.name = 'custom_name' }

      it "returns the custom name" do
        expect(subject.name).to eq 'custom_name'
      end
    end    
  end

  describe "#caption" do
    let(:name) { "field_name" }
    let(:caption) { FieldCaption.generate(name) } # "Field Name"
    
    context "when a custom caption is NOT defined" do
      before { subject.name = name }

      it "returns a caption generated from the name" do
        expect(subject.caption).to eq caption
      end
    end
    
    context "when a custom caption is defined" do
      before { subject.caption = "Custom Caption" }

      it "returns the custom caption" do
        expect(subject.caption).to eq "Custom Caption"
      end
    end
  end

  describe "#breakdown" do
    context "when not defined" do
      it 'returns true' do
        expect(subject.breakdown).to be_truthy
      end
    end
     
    context "when is set to false" do
      before { subject.breakdown = false }
      it 'returns false' do
        expect(subject.breakdown).to be_falsey
      end
    end
  end
  
  describe "#column_table" do
    before { concrete_field.position = 2 }

    let (:table_name) do
      datasource_name = concrete_field.datasource.name
      "datafiles.#{datasource_name}_f002"
    end

    describe "#column_table" do
      it "returns its column table name" do
        expect(concrete_field.column_table).to eq table_name
      end
    end
  end

  describe "#ui_data_type" do
    let(:db_data_type) { "some DB type" }
    before { subject.db_data_type = db_data_type }

    context 'when the ui_data_type is NOT defined' do
      it 'returns the db_data_type' do
        expect(subject.ui_data_type).to eq db_data_type
      end
    end

    context 'when the ui_data_type is defined' do
      let(:ui_data_type) { "some UI type" }
      before { subject.ui_data_type = ui_data_type }

      it 'returns the ui_data_type' do
        expect(subject.ui_data_type).to eq ui_data_type
      end
    end
  end

  describe "#default_lookup_class" do
    let(:lookup_model) { FactoryGirl.build(:default_lookup_model_builder) }

    before do
      allow(DefaultLookupModelBuilder).to(
        receive(:new)
          .with(subject)
          .and_return(lookup_model)
      )
    end

    it 'returns a new model generated using DefaultLookupModelBuilder' do
      expect(subject.default_lookup_class).to eq lookup_model.build_model
    end

    context 'when it was already invoked' do
      before { subject.default_lookup_class }

      it "retuns the memoized value instead of building the model again" do
        subject.default_lookup_class
        expect(DefaultLookupModelBuilder).to have_received(:new).once
      end
    end
  end

  %w[on off].each do |on_or_off|
    method = :"binary_#{on_or_off}_value"
    unsafe_method = :"unsafe_binary_#{on_or_off}_value"
    describe "##{method}" do
      let(:invoke) { subject.send(method) }

      context "when the ui_data_type == 'binary'" do
        let(:value) { 'whatever' }

        before do
          subject.ui_data_type = 'binary'
          allow(subject).to(receive(unsafe_method).and_return(value))
        end

        shared_examples 'returns the correct value' do
          it 'returns the correct value' do
            expect(invoke).to eq value
          end
        end

        context 'when it has NOT been called' do
          it_behaves_like 'returns the correct value'

          it "retrieves it from its 'default_lookup_class'" do
            expect(subject).to receive(unsafe_method)
            invoke
          end
        end

        context 'when it was already called' do
          before { subject.send(method) }
          
          it_behaves_like 'returns the correct value'

          it "does NOT retrieve it from its 'default_lookup_class'" do
            expect(subject).to_not receive(unsafe_method)
            invoke
          end
        end
      end

      context "when the ui_data_type != 'binary'" do
        before { subject.ui_data_type = 'string' }

        it 'raises a NoMethodError' do
          expect { invoke }.to raise_error(NoMethodError, /for.*ui_data_type/)
        end
      end
    end #describe
  end #binary_{on/off}_value

  describe '#format_value' do
    let(:value) { 500.42 }
    
    context 'when no printf_format defined' do
      it 'returns the value' do
        expect(concrete_field.format_value(value)).to eq value
      end
    end

    context 'when printf_format is defined' do
      before { concrete_field.printf_format = '%.3f' }
      
      it 'returns the value' do
        expect(concrete_field.format_value(value)).to eq '500.420'
      end
    end

    context 'when value is nil' do
      it "returns '(Blank)'" do
        expect(concrete_field.format_value(nil)).to eq '(Blank)'
      end
    end

  end

end

