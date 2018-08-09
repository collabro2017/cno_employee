require 'spec_helper'

describe "Count pages" do

  subject { page }

  describe "index" do

    let(:user) { FactoryGirl.create(:user) }
    let(:datasource) { FactoryGirl.create(:datasource, name: "auto_file") }

    before do   
      sign_in user
      visit counts_path
    end

    it { should have_title('All counts') }
    it { should have_content ('All counts') }

    describe "pagination" do
      
      before do
        35.times { FactoryGirl.create(:count, datasource: datasource, user: user) }
        visit current_path  # refresh view now that we have 35 conts
      end

      it { should have_selector('div.pagination') }

      it "should list each count" do
        Count.order("id DESC").paginate(page: 1).each do |count|
          expect(page).to have_selector('td', text: count.name)
          expect(page).to have_selector('td', text: count.datasource.name)
          
          expect(page).to have_css("td[title='#{count.last_run_at}']")
          expect(page).to have_selector('td', text: count.last_run_at(true))
          
          expect(page).to have_css("td[title='#{count.tidy_result}']")
          expect(page).to have_selector('td', text: count.tidy_result(human: true))

        end
      end

      it "should list counts from the second page" do
        visit "#{counts_path}?page=2"
        Count.order("id DESC").paginate(page: 2).each do |count|
          expect(page).to have_selector('td', text: count.name)
        end
      end

      it "should not go beyond the last page" do
        pending
        visit "#{counts_path}?page=3"
      end

    end

    describe "when there are records to display" do

      before do
        FactoryGirl.create(:count, datasource: datasource, user: user)
        visit current_path
      end

      describe "show table contents" do
        it { should have_selector('th', text: "Name") }
        it { should have_selector('th', text: "Datasource") }
        it { should have_selector('th', text: "Last run") }
        it { should have_selector('th', text: "Result") }
      end
    end

    describe "when there aren't records to display" do
      Count.delete_all
      it { should have_content("No counts to show, where did they all go?") }
    end


  end
end