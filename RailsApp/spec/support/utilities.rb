def full_title(page_title)
  base_title = "Runawaybit's CnO"
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end

def sign_in(user)
  visit signin_path
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
end

def guaranteed_unique_symbol(length)
  ret = [*('a'..'z')].sample(1)
  (length-1).times do
    ret << [*('a'..'z'),*('0'..'9'),'_'].sample(1)[0]
  end
  ret.join('')
end
