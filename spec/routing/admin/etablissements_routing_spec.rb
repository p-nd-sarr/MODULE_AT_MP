require "rails_helper"

RSpec.describe Admin::EtablissementsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/etablissements").to route_to("admin/etablissements#index")
    end

    it "routes to #new" do
      expect(get: "/admin/etablissements/new").to route_to("admin/etablissements#new")
    end

    it "routes to #show" do
      expect(get: "/admin/etablissements/1").to route_to("admin/etablissements#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/etablissements/1/edit").to route_to("admin/etablissements#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/etablissements").to route_to("admin/etablissements#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/etablissements/1").to route_to("admin/etablissements#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/etablissements/1").to route_to("admin/etablissements#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/etablissements/1").to route_to("admin/etablissements#destroy", id: "1")
    end
  end
end
