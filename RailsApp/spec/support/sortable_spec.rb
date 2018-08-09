shared_examples "sortable" do |scope_attribute|

  describe "position updates before save" do       
    context "when there aren't other objects within the scope" do
      context "when inserting one object" do
        context "when the position is NOT specified (nil)" do
          it "gets saved with position = 0" do
            subject.save!
            expect(subject.position).to eq 0
          end
        end

        context "when the position is specified" do
          before { subject.position = 4 }
          it "gets saved with position = 0" do
            subject.save!
            expect(subject.position).to eq 0
          end
        end
      end

      context "when inserting multiple objects" do
        let(:objects) do
          scope_criteria = { scope_attribute => subject.scope_value }
          subject.class.where(scope_criteria).order(:position)
        end

        examples = [
            {positions: [0,1,0], expected_result: [3,1,2]},
            {positions: [0,1,1], expected_result: [1,3,2]}
          ]
        examples.each do |example|
          positions = example[:positions]
          expected_result = example[:expected_result]
          
          context "when inserting in positions: #{positions}" do
            before do
              positions.each_with_index do |position, i|
                object = subject.dup
                object.id = i + 1
                object.position = position
                object.save!
              end
            end
            
            specify "the ids ordered by position are: #{expected_result}" do
              expect(objects.map(&:id)).to eq expected_result
            end
            
            specify "the positions are: #{(0...positions.length).to_a}" do
              expect(objects.map(&:position)).to eq (0...positions.length).to_a
            end
          end
        end
      end
    end

    context "when there are 4 objects of the same scope and 2 of another" do
      let(:objects) do
        scope_criteria = { scope_attribute => subject.scope_value }
        subject.class.where(scope_criteria).order(:position)
      end

      let(:list) { objects.map(&:id) }
      let(:positions) { objects.map(&:position) }
      
      before do
        4.times do |i|
          object = subject.dup
          object.id = i + 1
          object.save!
        end

        scope_object = subject.scope_value.dup

        [5,6].each do |i|
          object = subject.dup
          object.id = i
          object.scope_value = scope_object
          object.save!
        end        
        
        subject.id = 7        
      end

      context "when adding to the end of the list" do
        it "does NOT change the position of the other items" do
          subject.position = 4
          subject.save!
          expect(list).to eq [1, 2, 3, 4, 7]
          expect(positions).to eq [0, 1, 2, 3, 4]
        end
      end

      context "when inserting at another item's position (1)" do
        it "increases the position of the higher items" do
          subject.position = 1
          subject.save!
          expect(list).to eq [1, 7, 2, 3, 4]
          expect(positions).to eq [0, 1, 2, 3, 4]
        end
      end

      context "when inserting at a position higher than the size of the list" do
        it "gets saved with a position equal to the size of the list" do
          subject.position = 9
          subject.save!
          expect(list).to eq [1, 2, 3, 4, 7]
          expect(positions).to eq [0, 1, 2, 3, 4]
        end
      end

      context "when moving item from position 0 to position 3" do
        it "updates the positions of the others" do
          to_move = objects.find_by(position: 0)
          to_move.position = 3
          to_move.save!
          expect(list).to eq [2, 3, 4, 1]
          expect(positions).to eq [0, 1, 2, 3]
        end
      end

      context "when moving item from position 3 to position 0" do
        it "updates the positions of the others" do
          to_move = objects.find_by(position: 3)
          to_move.position = 0
          to_move.save!
          expect(list).to eq [4, 1, 2, 3]
          expect(positions).to eq [0, 1, 2, 3]
        end
      end

      context "when moving item from position 1 to position 2" do
        it "updates the positions of the others" do
          to_move = objects.find_by(position: 1)
          to_move.position = 2
          to_move.save!
          expect(list).to eq [1, 3, 2, 4]
          expect(positions).to eq [0, 1, 2, 3]
        end
      end

      context "when moving item from position 2 to position 1" do
        it "updates the positions of the others" do
          to_move = objects.find_by(position: 2)
          to_move.position = 1
          to_move.save!
          expect(list).to eq [1, 3, 2, 4]
          expect(positions).to eq [0, 1, 2, 3]
        end
      end
      
    end
  end  
  
  describe "position updates after destroy" do
    let(:objects) do
      scope_criteria = { scope_attribute => subject.scope_value }
      subject.class.where(scope_criteria).order(:position)
    end
    
    context "when there are 4 objects of the same scope and 2 of another" do
      let(:list) { objects.map(&:id) }
      let(:positions) { objects.map(&:position) }

      before do
        4.times do |i|
          object = subject.dup
          object.id = i + 1
          object.save!
        end

        scope_object = subject.scope_value.dup

        [5, 6].each do |i|
          object = subject.dup
          object.id = i
          object.scope_value = scope_object
          object.save!
        end        
      end

      context "when destroying the first one" do
        it "decreases the position of survivor items" do
          first_one = objects.find_by(position: 0)
          first_one.destroy
          expect(list).to eq [2, 3, 4]
          expect(positions).to eq [0, 1, 2]
        end
      end
        
      context "when destroying the second one" do
        it "decreases the position of the higher items" do
          second_one = objects.find_by(position: 1)
          second_one.destroy
          expect(list).to eq [1, 3, 4]
          expect(positions).to eq [0, 1, 2]
        end
      end
      
      context "when destroying the last one" do
        it "does NOT change the position of the other items" do
          last_one = objects.find_by(position: 3)
          last_one.destroy
          expect(list).to eq [1, 2, 3]
          expect(positions).to eq [0, 1, 2]
        end
      end
    end
  end  

  describe "::default_scope" do
    let(:positions) { [3, 0, 2, 1] }

    before do      
      positions.each do |position|
        object = subject.dup
        object.position = position
        object.save!
      end
    end
 
    specify "[Sortable Class].all returns them sorted by position" do
      expect(subject.class.all.pluck(:position)).to eq positions.sort
    end
  end
end
