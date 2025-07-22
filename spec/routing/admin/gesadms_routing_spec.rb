require "rails_helper"

RSpec.describe Admin::GesadmsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/gesadms").to route_to("admin/gesadms#index")
    end

    it "routes to #new" do
      expect(get: "/admin/gesadms/new").to route_to("admin/gesadms#new")
    end

    it "routes to #show" do
      expect(get: "/admin/gesadms/1").to route_to("admin/gesadms#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/gesadms/1/edit").to route_to("admin/gesadms#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/gesadms").to route_to("admin/gesadms#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/gesadms/1").to route_to("admin/gesadms#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/gesadms/1").to route_to("admin/gesadms#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/gesadms/1").to route_to("admin/gesadms#destroy", id: "1")
    end
  end
end
