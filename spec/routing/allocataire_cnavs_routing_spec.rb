require "rails_helper"

RSpec.describe AllocataireCnavsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/allocataire_cnavs").to route_to("allocataire_cnavs#index")
    end

    it "routes to #new" do
      expect(get: "/allocataire_cnavs/new").to route_to("allocataire_cnavs#new")
    end

    it "routes to #show" do
      expect(get: "/allocataire_cnavs/1").to route_to("allocataire_cnavs#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/allocataire_cnavs/1/edit").to route_to("allocataire_cnavs#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/allocataire_cnavs").to route_to("allocataire_cnavs#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/allocataire_cnavs/1").to route_to("allocataire_cnavs#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/allocataire_cnavs/1").to route_to("allocataire_cnavs#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/allocataire_cnavs/1").to route_to("allocataire_cnavs#destroy", id: "1")
    end
  end
end
