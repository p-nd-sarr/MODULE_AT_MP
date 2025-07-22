require "rails_helper"

RSpec.describe Admin::CommunesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/communes").to route_to("admin/communes#index")
    end

    it "routes to #new" do
      expect(get: "/admin/communes/new").to route_to("admin/communes#new")
    end

    it "routes to #show" do
      expect(get: "/admin/communes/1").to route_to("admin/communes#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/communes/1/edit").to route_to("admin/communes#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/communes").to route_to("admin/communes#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/communes/1").to route_to("admin/communes#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/communes/1").to route_to("admin/communes#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/communes/1").to route_to("admin/communes#destroy", id: "1")
    end
  end
end
