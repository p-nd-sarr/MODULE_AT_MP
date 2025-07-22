require "rails_helper"

RSpec.describe Admin::AssociationAllocatairesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/association_allocataires").to route_to("admin/association_allocataires#index")
    end

    it "routes to #new" do
      expect(get: "/admin/association_allocataires/new").to route_to("admin/association_allocataires#new")
    end

    it "routes to #show" do
      expect(get: "/admin/association_allocataires/1").to route_to("admin/association_allocataires#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/association_allocataires/1/edit").to route_to("admin/association_allocataires#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/association_allocataires").to route_to("admin/association_allocataires#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/association_allocataires/1").to route_to("admin/association_allocataires#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/association_allocataires/1").to route_to("admin/association_allocataires#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/association_allocataires/1").to route_to("admin/association_allocataires#destroy", id: "1")
    end
  end
end
