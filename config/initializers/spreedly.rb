#setup Spreedly
if Rails.env.development? then
  ENV['SPREEDLYCORE_ENVIRONMENT_KEY']='1EDmlJd9d0sfv1E56NKeTjNFJ66'
  ENV['SPREEDLYCORE_ACCESS_SECRET']='O4lB16v76XS4hVQPIJT4rU7zSas3e4sueE2JHNkQSJUTIovitVYHwb9LuvSG4xMq'
	ENV['SPREEDLYCORE_GATEWAY_TOKEN']='8vAakAjstrG9k9jeLBhDARNoAic'
end
#testing environment for now
SpreedlyCore.configure
