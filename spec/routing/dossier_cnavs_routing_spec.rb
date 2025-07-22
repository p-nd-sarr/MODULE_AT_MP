require "rails_helper"

RSpec.describe DossierCnavsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/dossier_cnavs").to route_to("dossier_cnavs#index")
    end

    it "routes to #new" do
      expect(get: "/dossier_cnavs/new").to route_to("dossier_cnavs#new")
    end

    it "routes to #show" do
      expect(get: "/dossier_cnavs/1").to route_to("dossier_cnavs#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/dossier_cnavs/1/edit").to route_to("dossier_cnavs#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/dossier_cnavs").to route_to("dossier_cnavs#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/dossier_cnavs/1").to route_to("dossier_cnavs#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/dossier_cnavs/1").to route_to("dossier_cnavs#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/dossier_cnavs/1").to route_to("dossier_cnavs#destroy", id: "1")
    end
  end
end
