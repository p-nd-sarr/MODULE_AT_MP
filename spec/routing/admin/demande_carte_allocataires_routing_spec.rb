require "rails_helper"

RSpec.describe Admin::DemandeCarteAllocatairesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/demande_carte_allocataires").to route_to("admin/demande_carte_allocataires#index")
    end

    it "routes to #new" do
      expect(get: "/admin/demande_carte_allocataires/new").to route_to("admin/demande_carte_allocataires#new")
    end

    it "routes to #show" do
      expect(get: "/admin/demande_carte_allocataires/1").to route_to("admin/demande_carte_allocataires#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/demande_carte_allocataires/1/edit").to route_to("admin/demande_carte_allocataires#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/demande_carte_allocataires").to route_to("admin/demande_carte_allocataires#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/demande_carte_allocataires/1").to route_to("admin/demande_carte_allocataires#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/demande_carte_allocataires/1").to route_to("admin/demande_carte_allocataires#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/demande_carte_allocataires/1").to route_to("admin/demande_carte_allocataires#destroy", id: "1")
    end
  end
end
