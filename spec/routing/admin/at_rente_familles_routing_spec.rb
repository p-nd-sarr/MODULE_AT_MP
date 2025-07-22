require "rails_helper"

RSpec.describe Admin::AtRenteFamillesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/at_rente_familles").to route_to("admin/at_rente_familles#index")
    end

    it "routes to #new" do
      expect(get: "/admin/at_rente_familles/new").to route_to("admin/at_rente_familles#new")
    end

    it "routes to #show" do
      expect(get: "/admin/at_rente_familles/1").to route_to("admin/at_rente_familles#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/at_rente_familles/1/edit").to route_to("admin/at_rente_familles#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/at_rente_familles").to route_to("admin/at_rente_familles#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/at_rente_familles/1").to route_to("admin/at_rente_familles#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/at_rente_familles/1").to route_to("admin/at_rente_familles#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/at_rente_familles/1").to route_to("admin/at_rente_familles#destroy", id: "1")
    end
  end
end
