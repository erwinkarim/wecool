#class AppMailer < ActionMailer::Base
class AppMailer < Devise::Mailer
  layout 'mail'
  helper :application
  default from: "no-reply@sirap.co"

  def test_mail persona
    @persona = persona
    @msg = 'Testing one, two, three'

    mail(:to => @persona.email, :subject => "Test")
  end 

  #to share photos/sets to other people using email
  def share options={}
    @default_options = { :from => 'Sirap <no-reply@sirap.co>', :to => 'devnull@sirap.co',  :subject => 'the subject', 
      :url => 'http://sirap.co/', :persona_sender => nil, :message => nil }
    @default_options = @default_options.merge options

    mail(:to => @default_options[:to], :subject => @default_options[:subject], :from => @default_options[:from] ) do |format|
      format.html { render :layout => 'mail' }
    end
  end

  def feedback option={}
    @default_options = { :from => 'Sirap <no-reply@sirap.co>', :comments => '' , :url => '/' }
    @default_options = @default_options.merge option

    mail( :to => 'feedback@sirap.co', :subject => 'customer feedback', :from => @default_options[:from]) do |format|
      format.html { render :layout => 'mail' }
    end
  end
end
