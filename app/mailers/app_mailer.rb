#class AppMailer < ActionMailer::Base
class AppMailer < Devise::Mailer
  helper :application
  default from: "from@example.com"

  def test_mail persona
    @persona = persona
    @msg = 'Testing one, two, three'

    mail(:to => @persona.email, :subject => "Test")
  end 

  def share options={}
    @default_options = { :from => 'no-reply@wecool.com', :to => 'test@wecool.com',  :subject => 'the subject', 
      :url => 'http://localhost:3000/test', :persona_sender => nil, :message => nil }
    @default_options = @default_options.merge options

    mail(:to => @default_options[:to], :subject => @default_options[:subject], :from => @default_options[:from] ) do |format|
      format.html { render :layout => 'mail' }
    end
  end
end
