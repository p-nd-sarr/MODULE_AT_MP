require "rails_helper"

RSpec.describe Admin::BanqueAgencesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/banque_agences").to route_to("admin/banque_agences#index")
    end

    it "routes to #new" do
      expect(get: "/admin/banque_agences/new").to route_to("admin/banque_agences#new")
    end

    it "routes to #show" do
      expect(get: "/admin/banque_agences/1").to route_to("admin/banque_agences#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/banque_agences/1/edit").to route_to("admin/banque_agences#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/banque_agences").to route_to("admin/banque_agences#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/banque_agences/1").to route_to("admin/banque_agences#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/banque_agences/1").to route_to("admin/banque_agences#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/banque_agences/1").to route_to("admin/banque_agences#destroy", id: "1")
    end
  end
end
