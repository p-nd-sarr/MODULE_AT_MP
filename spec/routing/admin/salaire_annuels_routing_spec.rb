require "rails_helper"

RSpec.describe Admin::SalaireAnnuelsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/salaire_annuels").to route_to("admin/salaire_annuels#index")
    end

    it "routes to #new" do
      expect(get: "/admin/salaire_annuels/new").to route_to("admin/salaire_annuels#new")
    end

    it "routes to #show" do
      expect(get: "/admin/salaire_annuels/1").to route_to("admin/salaire_annuels#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/salaire_annuels/1/edit").to route_to("admin/salaire_annuels#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/salaire_annuels").to route_to("admin/salaire_annuels#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/salaire_annuels/1").to route_to("admin/salaire_annuels#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/salaire_annuels/1").to route_to("admin/salaire_annuels#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/salaire_annuels/1").to route_to("admin/salaire_annuels#destroy", id: "1")
    end
  end
end
