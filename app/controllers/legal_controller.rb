# frozen_string_literal: true

# Sert les pages légales statiques générées depuis config/legal/*.fr.md
# via rake legal:build.
#
# Routes :
#   GET /conditions-utilisation  → legal#cgu
#   GET /mentions-legales        → legal#mentions_legales
class LegalController < ApplicationController
  layout "darkswarm"

  def cgu
    @title = t("legal.cgu.title")
    render "legal/cgu"
  end

  def mentions_legales
    @title = t("legal.mentions_legales.title")
    render "legal/mentions_legales"
  end
end
