def angular_login(user)
  fill_in 'sign_on_field', with: user.email
  fill_in 'password_field', with: user.password
  click_button("Sign In")
end

def angular_logout(user)
  logout(user)
  click_button("#{user.email}")
  find('a', :text => "Sign Out").click
  visit root_path
end

def set_auth_headers(user)
	request.headers["X-User-Token"] = "#{user.authentication_token}"
	request.headers["X-User-Email"] = "#{user.email}"
end