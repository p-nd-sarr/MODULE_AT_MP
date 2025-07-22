require "rails_helper"

RSpec.describe Admin::DepartementsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/departements").to route_to("admin/departements#index")
    end

    it "routes to #new" do
      expect(get: "/admin/departements/new").to route_to("admin/departements#new")
    end

    it "routes to #show" do
      expect(get: "/admin/departements/1").to route_to("admin/departements#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/departements/1/edit").to route_to("admin/departements#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/departements").to route_to("admin/departements#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/departements/1").to route_to("admin/departements#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/departements/1").to route_to("admin/departements#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/departements/1").to route_to("admin/departements#destroy", id: "1")
    end
  end
end
