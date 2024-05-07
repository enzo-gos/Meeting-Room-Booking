class ApplicationMailer < ActionMailer::Base
  default from: ENV['MAIL_SERVICE_USERNAME']
  layout 'mailer'
end
