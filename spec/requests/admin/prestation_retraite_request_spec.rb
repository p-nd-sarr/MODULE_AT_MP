require 'rails_helper'

RSpec.describe "Admin::PrestationRetraites", type: :request do

  describe "GET /index" do
    it "returns http success" do
      get "/admin/prestation_retraite/index"
      expect(response).to have_http_status(:success)
    end
  end

end
