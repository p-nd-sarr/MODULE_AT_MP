require "rails_helper"

RSpec.describe Admin::LocaliteGrappesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/localite_grappes").to route_to("admin/localite_grappes#index")
    end

    it "routes to #new" do
      expect(get: "/admin/localite_grappes/new").to route_to("admin/localite_grappes#new")
    end

    it "routes to #show" do
      expect(get: "/admin/localite_grappes/1").to route_to("admin/localite_grappes#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/localite_grappes/1/edit").to route_to("admin/localite_grappes#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/localite_grappes").to route_to("admin/localite_grappes#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/localite_grappes/1").to route_to("admin/localite_grappes#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/localite_grappes/1").to route_to("admin/localite_grappes#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/localite_grappes/1").to route_to("admin/localite_grappes#destroy", id: "1")
    end
  end
end
