require 'spec_helper'

describe "Authentication" do
  subject { page }

  describe "Sign in page" do 
    before { visit signin_path }
    it { should have_content 'Sign in' }
    it { should have_title 'Sign in' }
  end

  describe "Sign in" do
    before { visit signin_path }

    describe "with invalid username and password" do
      before { click_button  'Sign in'}  
      it { should have_title 'Sign in' }
      it { should have_selector 'div.alert.alert-error', text: 'Ops! You entered a wrong email/password combination' }
    end

    describe "after visiting another page" do
      before { click_link 'Home' }
      it { should_not have_selector('div.alert.alert-error') }
    end

    describe "with valid username and password" do
      let (:user) { FactoryGirl.create(:user) }
      
      before do 
        fill_in 'Email', with: user.email.upcase
        fill_in 'Password', with: user.password
        click_button  'Sign in'
      end
      
      it { should have_title user.name }
      it { should have_link "Profile", href:user_path(user) }
      it { should have_link "Sign out", href:signout_path }
      it { should_not have_link "Sign in", href:signin_path }

      describe "followed by sign out" do
        before { click_link 'Sign out' }
        it { should have_link 'Sign in' }

      end
    end
  end

  describe "authorization" do
    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
     
      describe "in the users controller" do
       
        describe "visiting the show page" do
          before { visit user_path(user) }

          it{ should have_title 'Sign in'}
        end

        describe "submitting to the update action" do
          pending "no update actions to test yet"
        #   before { patch user_path(user) }
        #   specify { expect(response).to redirect_to(signin_path)}
        end
      end

      describe "in counts controller" do
        describe "visiting the counts index" do
          before { visit counts_path }
          it { should have_title('Sign in') }
        end

      end


      describe "when attempting to visit a protected page" do
        before do
          visit user_path(user)
          fill_in "Email", with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do
          it "should render the desired protected page" do
            expect(page).to have_title(user.name)
          end
        end
      end



    end

    describe "as wrong user" do
      let (:user) { FactoryGirl.create :user }
      let (:wrong_user) { FactoryGirl.create :user, email: "wrong@example.com" }
      before { sign_in user }

      describe "visiting Users#show page" do
        before { visit user_path(wrong_user) }
        it { should_not have_title(full_title(user.name)) }
      end

      describe "submitting a PATCH request to the Users#update action" do
        pending "no update actions to test yet"
        #before { patch user_path(wrong_user) }
        #specify { expect(response).to redirect_to(root_path) }
      end

    end


  end



end
