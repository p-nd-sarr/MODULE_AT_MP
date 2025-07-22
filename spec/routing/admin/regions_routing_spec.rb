require "rails_helper"

RSpec.describe Admin::RegionsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/regions").to route_to("admin/regions#index")
    end

    it "routes to #new" do
      expect(get: "/admin/regions/new").to route_to("admin/regions#new")
    end

    it "routes to #show" do
      expect(get: "/admin/regions/1").to route_to("admin/regions#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/regions/1/edit").to route_to("admin/regions#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/regions").to route_to("admin/regions#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/regions/1").to route_to("admin/regions#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/regions/1").to route_to("admin/regions#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/regions/1").to route_to("admin/regions#destroy", id: "1")
    end
  end
end
