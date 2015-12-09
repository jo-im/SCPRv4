class ApplicationMailer < ActionMailer::Base
  prepend_view_path 'app/views/mailers'
  default from: 'scprweb@scpr.org'
end