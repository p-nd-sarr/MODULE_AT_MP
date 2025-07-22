require "rails_helper"

RSpec.describe CfsReversionVeuvesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/prestation_ext_frances").to route_to("prestation_ext_frances#index")
    end

    it "routes to #new" do
      expect(get: "/prestation_ext_frances/new").to route_to("prestation_ext_frances#new")
    end

    it "routes to #show" do
      expect(get: "/prestation_ext_frances/1").to route_to("prestation_ext_frances#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/prestation_ext_frances/1/edit").to route_to("prestation_ext_frances#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/prestation_ext_frances").to route_to("prestation_ext_frances#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/prestation_ext_frances/1").to route_to("prestation_ext_frances#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/prestation_ext_frances/1").to route_to("prestation_ext_frances#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/prestation_ext_frances/1").to route_to("prestation_ext_frances#destroy", id: "1")
    end
  end
end
