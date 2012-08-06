require "spec_helper"

describe UserMailer do
  describe "reset_password" do

    let(:email)                 { 'foo@example.com' }
    let(:reset_password_token)  { 'abc123' }
    let(:from)                  { Rails.application.config.default_mail_from }
    let(:user)  {
      mock_model(
        User, :email => email, :reset_password_token => reset_password_token
      )
    }

    subject{ UserMailer.reset_password(user) }

    specify do
      subject.subject.should eq("Password reset instructions")
      subject.to.should eq([email])
      subject.from.should eq([from])
      subject.body.encoded.should match("Follow this link to reset your password.")
    end
  end

end
