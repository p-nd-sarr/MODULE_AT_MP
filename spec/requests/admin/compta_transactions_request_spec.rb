require 'rails_helper'

RSpec.describe "Admin::ComptaTransactions", type: :request do

  describe "GET /index" do
    it "returns http success" do
      get "/admin/compta_transactions/index"
      expect(response).to have_http_status(:success)
    end
  end

end
