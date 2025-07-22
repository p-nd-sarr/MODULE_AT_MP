require "rails_helper"

RSpec.describe DeclarationDivorceOuDecesConjointsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/declaration_divorce_ou_deces_conjoints").to route_to("declaration_divorce_ou_deces_conjoints#index")
    end

    it "routes to #new" do
      expect(get: "/declaration_divorce_ou_deces_conjoints/new").to route_to("declaration_divorce_ou_deces_conjoints#new")
    end

    it "routes to #show" do
      expect(get: "/declaration_divorce_ou_deces_conjoints/1").to route_to("declaration_divorce_ou_deces_conjoints#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/declaration_divorce_ou_deces_conjoints/1/edit").to route_to("declaration_divorce_ou_deces_conjoints#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/declaration_divorce_ou_deces_conjoints").to route_to("declaration_divorce_ou_deces_conjoints#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/declaration_divorce_ou_deces_conjoints/1").to route_to("declaration_divorce_ou_deces_conjoints#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/declaration_divorce_ou_deces_conjoints/1").to route_to("declaration_divorce_ou_deces_conjoints#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/declaration_divorce_ou_deces_conjoints/1").to route_to("declaration_divorce_ou_deces_conjoints#destroy", id: "1")
    end
  end
end
