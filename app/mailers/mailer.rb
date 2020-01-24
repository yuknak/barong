# frozen_string_literal: true

class Mailer < ApplicationMailer
  layout 'mailer'

  def process_payload
    @record  = params[:record]
    @changes = params[:changes]
    @user    = params[:user]

    sender = "#{Barong::App.config.sender_name} <#{Barong::App.config.sender_email}>"

    attachments.inline['logo.png'] = File.read('./public/logo.png')

    email_options = {
      subject: params[:subject],
      template_name: params[:template_name],
      from: sender,
      to: @user.email
    }

    mail(email_options)
  end
end
