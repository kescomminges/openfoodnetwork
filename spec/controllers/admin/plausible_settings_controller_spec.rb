# frozen_string_literal: true

RSpec.describe Admin::PlausibleSettingsController do
  describe "#update" do
    let(:params) {
      {
        preferences: {
          plausible_domain: "kescomminges.fr",
          plausible_script_url: "https://plausible.s-entraider.net/js/script.file-downloads.hash.outbound-links.js",
        }
      }
    }

    before do
      allow(controller).to receive(:spree_current_user) { create(:admin_user) }
    end

    it "changes Plausible settings" do
      expect {
        post :update, params:
      }.to change {
        [
          Spree::Config[:plausible_domain],
          Spree::Config[:plausible_script_url],
        ]
      }.to(
        [
          "kescomminges.fr",
          "https://plausible.s-entraider.net/js/script.file-downloads.hash.outbound-links.js",
        ]
      )
    end
  end
end
