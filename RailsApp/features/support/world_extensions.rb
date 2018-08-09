require 'securerandom'

module CurrentUser
  def sign_in
    visit signin_path
    fill_in "Email", with: current_user.email
    fill_in "Password", with: current_user.password
    click_button "Sign in"
  end

  def successful_sign_in
    sign_in
    page.should have_content("Admin")
  end

end
World(CurrentUser)

module DirectDataManipulation

  def current_user
    @user ||= User.create!(name: 'Admin', email: 'cno+admin@runawaybit.com', 
      password: 'password', password_confirmation: 'password')
  end

  def current_datasource(name = guaranteed_unique_symbol(32))
    @datasource ||= Datasource.create!(name: name)
  end

  def new_datasource(name = guaranteed_unique_text(32))
    Datasource.create!(name: name)
  end

  def new_field(name = guaranteed_unique_symbol(64))
    field = Field.create!(name: name)
    3.times { field.datasources << current_datasource }
    field
  end

  def new_count(name = guaranteed_unique_text(64))
    Count.create!(name: name, user_id: current_user.id, datasource_id: current_datasource.id)
  end



  def guaranteed_unique_text(length)
    SecureRandom.urlsafe_base64(64)[0..length-1]
  end

  def guaranteed_unique_symbol(length)
    ret = [*('a'..'z')].sample(1)
    (length-1).times do
      ret << [*('a'..'z'),*('0'..'9'),'_'].sample(1)[0]
    end
    ret.join('')
  end


end
World(DirectDataManipulation)

