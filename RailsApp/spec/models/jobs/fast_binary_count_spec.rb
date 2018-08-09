require 'spec_helper'

describe Jobs::FastBinaryCount do

  subject(:fast_binary_count) { FactoryGirl.build(:fast_binary_count_job) }

  #--------------------------
  it "has a valid Factory" do
    expect(fast_binary_count).to be_valid
  end
  #--------------------------


  tasks = [
            OpenStruct.new({type: :query,           parameter: '<PARAM>'}),
            OpenStruct.new({type: :query_result,    parameter: '<PARAM>'}),
            OpenStruct.new({type: :binary,          parameter: '<PARAM>'}),
            OpenStruct.new({type: :binary_upload,   parameter: '<PARAM>'}),
            OpenStruct.new({type: :binary_download, parameter: '<PARAM>'}),
            OpenStruct.new({type: :binary_result,   parameter: nil})
          ]

  describe "#run" do
    let(:invoke) { fast_binary_count.run(nil) }
        
    tasks.each do |task|
      context "when the task is of type :#{task.type}" do
        before do
          fast_binary_count.count.stub(:fast_binary_tasks).and_return([task])
        end

        if task.parameter.nil?
          it "calls the method ##{task.type}" do
            expect(fast_binary_count).to(receive(task.type)).with(no_args)
            invoke
          end  
        else 
          it "calls the method ##{task.type} with #{task.parameter}" do
            expect(fast_binary_count).to(receive(task.type))
              .with(task.parameter)
            invoke
          end
        end
      end
    end
  end #run

end
