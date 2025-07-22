require "rails_helper"

RSpec.describe Admin::ComptaNaturePrestationsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/compta_nature_prestations").to route_to("admin/compta_nature_prestations#index")
    end

    it "routes to #new" do
      expect(get: "/admin/compta_nature_prestations/new").to route_to("admin/compta_nature_prestations#new")
    end

    it "routes to #show" do
      expect(get: "/admin/compta_nature_prestations/1").to route_to("admin/compta_nature_prestations#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/compta_nature_prestations/1/edit").to route_to("admin/compta_nature_prestations#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/compta_nature_prestations").to route_to("admin/compta_nature_prestations#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/compta_nature_prestations/1").to route_to("admin/compta_nature_prestations#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/compta_nature_prestations/1").to route_to("admin/compta_nature_prestations#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/compta_nature_prestations/1").to route_to("admin/compta_nature_prestations#destroy", id: "1")
    end
  end
end
