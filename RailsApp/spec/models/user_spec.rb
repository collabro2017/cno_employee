require 'spec_helper'

describe User do 

  subject(:user) { FactoryGirl.build(:user) }

  #--------------------------
	it "has a valid Factory" do
		expect(user).to be_valid
	end
	#--------------------------

  # associations
  it { is_expected.to belong_to :company }
  it { is_expected.to have_many :counts }
  it { is_expected.to have_many :orders }

  # validations
  it { is_expected.to validate_presence_of :first_name }
  it do
    is_expected.to ensure_length_of(:first_name).is_at_least(3).is_at_most(32)
  end
  it { is_expected.to_not allow_value('3@1#$}').for(:first_name) }
  it { is_expected.to_not allow_value('John Smith').for(:first_name) }
  it { is_expected.to allow_value('Eric-John').for(:first_name) }
  it { is_expected.to allow_value("D'Angelo").for(:first_name) }

  it { is_expected.to_not allow_value("3@1#$}").for(:last_name) }
  ['', "O'Neil", 'Johnson Smith', 'Johnson-Smith', 'St. Paul'].each do |lname|
    it { is_expected.to allow_value(lname).for(:last_name) }
  end

  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  %w[user@foo,com user_at_foo.org example.user@foo.].each do |invalid_email|
    it { is_expected.to_not allow_value(invalid_email).for(:email) }
  end

  it { is_expected.to have_secure_password }
  it { is_expected.to ensure_length_of(:password).is_at_least(6) }

  context 'when password is nil' do
    before { allow(user).to receive(:password).and_return(nil) }
    it { is_expected.to be_valid }
  end

  it { is_expected.to validate_presence_of :company }

  # enums
  it { is_expected.to respond_to(:status) }
  describe 'user status' do
    %w[pending active blocked].each do |status|
      context "when status is '#{status}' (valid)" do
        before { user.status = status }

        it { is_expected.to be_valid }
      end
    end

    context "when status is 'lost' (invalid)" do
      before { user.status = 'lost' }

      it { is_expected.to_not be_valid }
    end

    context "when status is nil" do
      before { user.status = nil }
      
      it "returns the default 'blocked'" do
        expect(user.status).to eq 'blocked'
      end
    end
  end

  # columns
  it { is_expected.to respond_to(:admin) }

  # hooks
  describe 'before_save hooks' do
    describe 'downcase email' do
      context 'when the email address has mixed case' do
        it 'returns saves it downcased' do
          user.email = 'Hugo@Mr-Clucks.com'
          user.save!
          expect(user.email).to eq 'hugo@mr-clucks.com'
        end
      end
    end

    describe 'strip last_name' do
      context 'when the last_name starts or ends with spaces' do
        it 'returns saves it striped' do
          user.last_name = '  Reyes '
          user.save!
          expect(user.last_name).to eq 'Reyes'
        end
      end
    end

    describe "generate remember token" do
      specify 'its remember token is not blank' do
        user.save!
        expect(user.remember_token).to_not be_blank
      end
    end    
  end

  # methods
  describe '#name' do
    context 'when last_name is nil' do
      it 'returns only the first_name with extra spaces squeezed' do
        user.first_name = '  Hugo      '
        user.last_name = nil
        expect(user.name).to eq "Hugo"
      end
    end

    context 'when last_name is not nil' do
      it 'returns first_name + last_name with extra spaces squeezed' do
        user.first_name = 'Hugo'
        user.last_name = 'Reyes   Reinas  '
        expect(user.name).to eq "Hugo Reyes Reinas"
      end
    end
  end

end

