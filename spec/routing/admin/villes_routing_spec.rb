require "rails_helper"

RSpec.describe Admin::VillesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/villes").to route_to("admin/villes#index")
    end

    it "routes to #new" do
      expect(get: "/admin/villes/new").to route_to("admin/villes#new")
    end

    it "routes to #show" do
      expect(get: "/admin/villes/1").to route_to("admin/villes#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/villes/1/edit").to route_to("admin/villes#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/villes").to route_to("admin/villes#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/villes/1").to route_to("admin/villes#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/villes/1").to route_to("admin/villes#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/villes/1").to route_to("admin/villes#destroy", id: "1")
    end
  end
end
