# frozen_string_literal: true

# Envoie les messages du formulaire de contact à contact@kescomminges.fr.
class ContactMailer < ApplicationMailer
  CONTACT_EMAIL = "contact@kescomminges.fr"

  def contact_message(name:, email:, subject:, message:)
    @sender_name    = name
    @sender_email   = email
    @sender_subject = subject.presence || t("contact_page.mailer.default_subject")
    @message        = message

    mail(
      to:       CONTACT_EMAIL,
      reply_to: "#{name} <#{email}>",
      subject:  "[Kescomminges] #{@sender_subject}"
    )
  end
end
