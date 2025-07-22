require "rails_helper"

RSpec.describe DemandeRemboursementCotisationsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/demande_remboursement_cotisations").to route_to("demande_remboursement_cotisations#index")
    end

    it "routes to #new" do
      expect(get: "/demande_remboursement_cotisations/new").to route_to("demande_remboursement_cotisations#new")
    end

    it "routes to #show" do
      expect(get: "/demande_remboursement_cotisations/1").to route_to("demande_remboursement_cotisations#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/demande_remboursement_cotisations/1/edit").to route_to("demande_remboursement_cotisations#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/demande_remboursement_cotisations").to route_to("demande_remboursement_cotisations#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/demande_remboursement_cotisations/1").to route_to("demande_remboursement_cotisations#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/demande_remboursement_cotisations/1").to route_to("demande_remboursement_cotisations#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/demande_remboursement_cotisations/1").to route_to("demande_remboursement_cotisations#destroy", id: "1")
    end
  end
end
