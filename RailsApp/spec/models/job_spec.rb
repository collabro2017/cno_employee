require 'spec_helper'
require 'time'

describe Job do
  before do
    @job = FactoryGirl.create(:job)
    
    # Oceanic Flight 815 aprox board time @ Sydney:
    @job.created_at = Time.parse("2004-09-22 13:30 +1000")

    # Oceanic Flight 815 aprox gate closed time @ Sydney:
    @job.queued_at = Time.parse("2004-09-22 14:00 +1000")
    
    # Oceanic Flight 815 departure @ Sydney:
    @job.running_at = Time.parse("2004-09-22 14:15 +1000")
    
    # Oceanic Flight 815 expected arrival @ LA:
    @job.finished_at = Time.parse("2004-09-22 10:42 -0700")
    
    # Oceanic Flight 815 crash time @ The Island (near Fiji)
    @job.failed_at = Time.parse("2004-09-22 16:16 +1200")
    
    # Oceanic Flight 815 realistic crash time (Sydney time)
    Time.stub(:now).and_return(Time.parse("2004-09-22 22:15 +1000"))
  end

  subject { @job }

  it { should respond_to(:type) }
  it { should respond_to(:sql) }
  it { should respond_to(:status) }
  
  # Delegated
  it { should respond_to(:active?) }
  it { should respond_to(:datasource) }

  it { should respond_to(:queued_at) }
  it { should respond_to(:running_at) }
  it { should respond_to(:finished_at) }
  it { should respond_to(:failed_at) }

  it { should belong_to(:count) }

  context "when status hasn't been defined yet" do
    its(:status) { should eq :pending }
  end

  context "when status is Pending" do
    before { @job.status = :pending }
    its(:active?) { should be_false }
    its(:total_time) { should be_nil }
    its(:raw_total_time) { should be_nil }
  end

  context "when it is active" do
    context "when status is Queued" do
      before { @job.status = :queued }
      its(:active?) { should be_true }
      its(:total_time) { should eq "8h 45m 0s" }
      its(:raw_total_time) { should eq 31_500 }
    end

    context "when status is Running" do
      before { @job.status = :running }
      its(:active?) { should be_true }
      its(:total_time) { should eq "8h 45m 0s" }
      its(:raw_total_time) { should eq 31_500 }
    end
  end

  context "when status is Finished" do
    before { @job.status = :finished }
    its(:active?) { should be_false }
    its(:total_time) { should eq "14h 12m 0s" }
    its(:raw_total_time) { should eq 51_120 }
  end

  context "when status is Failed" do
    before { @job.status = :failed }
    its(:active?) { should be_false }
    its(:total_time) { should eq "46m 0s" }
    its(:raw_total_time) { should eq 2_760 }
  end

  context "when it is of type Jobs::Count" do
    before { @job = FactoryGirl.create(:count_job) }
    
    its(:type) { should eq("Jobs::Count") }
    it { should respond_to(:result) }
  end

  context "when it is of type Jobs::Breakdown" do
    before { @job = FactoryGirl.create(:breakdown_job) }
    
    its(:type) { should eq("Jobs::Breakdown") }
    it { should respond_to(:result) }
  end

end
