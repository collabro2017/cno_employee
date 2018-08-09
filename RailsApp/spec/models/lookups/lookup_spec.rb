require 'spec_helper'

describe 'Lookups::LookupDummy' do
  
  subject(:lookup_dummy) { Lookups::LookupDummy.new() }
  
  context "when the fields are: 'season', 'episode' and 'character'" do
    before do
      LookupDummyBuilder.build_model(
        season: :integer, episode: :string, character: :string
      )
    end

    after do
      LookupDummyBuilder.destroy_model
    end
  
    describe "::first_filter_column" do
      it "returns a field name" do
        expect(Lookups::LookupDummy.first_filter_column).to eq :season
      end
    end

    describe "::fuzzy_filter_column" do
      it "returns a field name" do
        expect(Lookups::LookupDummy.fuzzy_filter_column).to eq :episode
      end
    end

    describe "::default_column" do
      it "returns a field name" do
        expect(Lookups::LookupDummy.default_column).to eq :character
      end
    end

    describe "::search" do
		  episodes = [
		    {season: 1, episode: 'Solitary', character: 'Sayid'},
		    {season: 2, episode: 'Collision', character: 'Ana Lucia'},
		    {season: 3, episode: 'I do', character: 'Kate'},
		    {season: 4, episode: 'Cabin Fever', character: 'Locke'}
		  ]

	    context "when #{episodes.map{ |e| e[:episode] }.to_sentence} exist" do
		    before do
			    episodes.each do |episode|
			      Lookups::LookupDummy.create!(episode)
			    end
		    end

		    context "when the search value is 'The End'" do
			    it "returns an empty collection" do
				    expect(Lookups::LookupDummy.search("The End")).to be_empty
			    end
		    end

		    %w[Co lli sion].each do |text|
			    context "when the search value is '#{text}'" do
				    let(:result) { Lookups::LookupDummy.search(text) }

				    it "returns one result" do
					    expect(result.count).to eq 1
				    end

				    it "the result's episode is 'Collision'" do
					    expect(result.first.episode).to eq "Collision"
				    end
			    end
		    end

		    context "when the search value is 'li'" do
			    let(:result) { Lookups::LookupDummy.search('li') }

			    it "returns two results" do
				    expect(result.count).to eq 2
			    end

			    ["Solitary", "Collision"].each do |episode|
				    it "has a result with the episode '#{episode}'" do
					    expect(result.pluck(:episode)).to include episode
				    end
			    end
		    end
		  end
    end # ::search
  end

end
