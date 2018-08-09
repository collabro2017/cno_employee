require 'spec_helper'

describe "Static pages" do
  subject { page }
  
  describe "welcome page" do
    before { visit root_path }

    it { should have_title("Runawaybit's CnO | Welcome") }
    it { should have_content('Welcome') }
  
  end
end
