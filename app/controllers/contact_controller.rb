# frozen_string_literal: true

# Formulaire de contact public — GET /contact, POST /contact
# Protégé par invisible_captcha (honeypot + timing).
class ContactController < ApplicationController
  layout "darkswarm"

  invisible_captcha only: :submit, honeypot: :firstname

  def show
    @title = t("contact_page.title")
  end

  def submit
    name    = params[:contact_name].to_s.strip
    email   = params[:contact_email].to_s.strip
    subject = params[:contact_subject].to_s.strip
    message = params[:contact_message].to_s.strip

    if name.blank? || email.blank? || message.blank?
      flash.now[:error] = t("contact_page.errors.blank_fields")
      @title = t("contact_page.title")
      return render :show
    end

    unless email.match?(URI::MailTo::EMAIL_REGEXP)
      flash.now[:error] = t("contact_page.errors.invalid_email")
      @title = t("contact_page.title")
      return render :show
    end

    ContactMailer.contact_message(name:, email:, subject:, message:).deliver_later

    redirect_to contact_path, notice: t("contact_page.success")
  end
end
