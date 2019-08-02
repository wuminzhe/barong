require_dependency 'barong/mock_sms'

Barong::App.define do |config|
  config.set(:twilio_phone_number, '+15005550000')
  config.set(:twilio_account_sid, '')
  config.set(:twilio_auth_token, '')
  config.set(:sms_content_template, 'Your verification code for Barong: {{code}}')
  config.set(:twilio_friendly_name, 'Barong')
end

sid = Barong::App.config.twilio_account_sid
token = Barong::App.config.twilio_auth_token
friendly_name = Barong::App.config.twilio_friendly_name

if sid == '' || token == ''
  if Rails.env.production?
    Rails.logger.fatal('No Twilio sid or token')
    raise 'FATAL: Twilio setup is invalid'
  end
  client = Barong::MockSMS.new(sid, token)
  service = ''
else
  client = Twilio::REST::Client.new(sid, token)
  service = client.verify.services.create(friendly_name: friendly_name).sid
end

Barong::App.define do |config|
  config.set(:sms_sender, client)
  config.set(:service, service)
end

Phonelib.strict_check = true
