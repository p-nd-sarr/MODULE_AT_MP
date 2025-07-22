require "rails_helper"

RSpec.describe Admin::QuartiersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/quartiers").to route_to("admin/quartiers#index")
    end

    it "routes to #new" do
      expect(get: "/admin/quartiers/new").to route_to("admin/quartiers#new")
    end

    it "routes to #show" do
      expect(get: "/admin/quartiers/1").to route_to("admin/quartiers#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/quartiers/1/edit").to route_to("admin/quartiers#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/quartiers").to route_to("admin/quartiers#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/quartiers/1").to route_to("admin/quartiers#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/quartiers/1").to route_to("admin/quartiers#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/quartiers/1").to route_to("admin/quartiers#destroy", id: "1")
    end
  end
end
