module RequestHelpers

  def header
    page.find('#header')
  end

  def sign_in_as(user, password = 'password')
    visit login_path
    fill_in 'Email',    :with => user.email
    fill_in 'Password', :with => password
    click_on 'Log in'
  end

end
