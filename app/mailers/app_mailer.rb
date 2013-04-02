#class AppMailer < ActionMailer::Base
class AppMailer < Devise::Mailer
  helper :application
  default from: "from@example.com"

  def test_mail persona
    @persona = persona
    @msg = 'Testing one, two, three'

    mail(:to => @persona.email, :subject => "Test")
  end 
end
