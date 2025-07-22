require "rails_helper"

RSpec.describe Admin::RentesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/rentes").to route_to("admin/rentes#index")
    end

    it "routes to #new" do
      expect(get: "/admin/rentes/new").to route_to("admin/rentes#new")
    end

    it "routes to #show" do
      expect(get: "/admin/rentes/1").to route_to("admin/rentes#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/rentes/1/edit").to route_to("admin/rentes#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/rentes").to route_to("admin/rentes#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/rentes/1").to route_to("admin/rentes#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/rentes/1").to route_to("admin/rentes#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/rentes/1").to route_to("admin/rentes#destroy", id: "1")
    end
  end
end
