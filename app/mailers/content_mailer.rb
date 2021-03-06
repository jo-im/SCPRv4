##
# ContentMailer
#
# Mailer for the ContentEmail class.
#
class ContentMailer < ApplicationMailer
  def email_content(attributes, obj_key)
    @msg      = ContentEmail.new(attributes)
    @content  = ContentBase.safe_obj_by_key!(obj_key)

    mail({
      :to       => @msg.to_email,
      :subject  => "#{@msg.from} " \
                   "has shared an article with you from 89.3 KPCC",
      :reply_to => @msg.from_email
    })
  end
end
