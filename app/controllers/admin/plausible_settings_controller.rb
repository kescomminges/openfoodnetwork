# frozen_string_literal: true

module Admin
  class PlausibleSettingsController < Spree::Admin::BaseController
    def update
      Spree::Config.set(preferences_params.to_h)

      respond_to do |format|
        format.html {
          redirect_to main_app.edit_admin_plausible_settings_path
        }
      end
    end

    private

    def preferences_params
      params.require(:preferences).permit(
        :plausible_domain,
        :plausible_script_url,
      )
    end
  end
end
