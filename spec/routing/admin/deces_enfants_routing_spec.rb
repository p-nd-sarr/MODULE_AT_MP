require "rails_helper"

RSpec.describe Admin::DecesEnfantsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/deces_enfants").to route_to("admin/deces_enfants#index")
    end

    it "routes to #new" do
      expect(get: "/admin/deces_enfants/new").to route_to("admin/deces_enfants#new")
    end

    it "routes to #show" do
      expect(get: "/admin/deces_enfants/1").to route_to("admin/deces_enfants#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/deces_enfants/1/edit").to route_to("admin/deces_enfants#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/deces_enfants").to route_to("admin/deces_enfants#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/deces_enfants/1").to route_to("admin/deces_enfants#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/deces_enfants/1").to route_to("admin/deces_enfants#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/deces_enfants/1").to route_to("admin/deces_enfants#destroy", id: "1")
    end
  end
end
