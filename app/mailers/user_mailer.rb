class UserMailer < ActionMailer::Base
  default :from => Rails.application.config.default_mail_from

  def reset_password(user)
    @user = user
    mail :to => @user.email, :subject => "Password reset instructions"
  end
end
