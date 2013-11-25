
#load default persona for photo seeding purpose
password = SecureRandom.hex

Persona.seed(:id,
# (id: integer, realname: string, created_at: datetime, updated_at: datetime, screen_name: string, up_votes: integer, down_votes: integer, avatar: string, email: string, encrypted_password: string, reset_password_token: string, reset_password_sent_at: datetime, remember_created_at: datetime, sign_in_count: integer, current_sign_in_at: datetime, last_sign_in_at: datetime, current_sign_in_ip: string, last_sign_in_ip: string, confirmation_token: string, confirmed_at: datetime, confirmation_sent_at: datetime, unconfirmed_email: string, agreeToTNC: boolean, premium: boolean, premiumSince: date, premiumExpire: date) 
	{ id: 1, realname: 'Sirap', screen_name: 'sirap', email: 'sirap@sirap.co', password:password, password_confirmation:password , agreeToTNC:true, premium: true, 
		premiumSince: DateTime.now, premiumExpire: DateTime.now + 99.year, avatar:nil, confirmed_at: DateTime.now}
)
