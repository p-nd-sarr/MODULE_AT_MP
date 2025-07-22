require "rails_helper"

RSpec.describe AtGuerisonsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/at_guerisons").to route_to("at_guerisons#index")
    end

    it "routes to #new" do
      expect(get: "/at_guerisons/new").to route_to("at_guerisons#new")
    end

    it "routes to #show" do
      expect(get: "/at_guerisons/1").to route_to("at_guerisons#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/at_guerisons/1/edit").to route_to("at_guerisons#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/at_guerisons").to route_to("at_guerisons#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/at_guerisons/1").to route_to("at_guerisons#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/at_guerisons/1").to route_to("at_guerisons#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/at_guerisons/1").to route_to("at_guerisons#destroy", id: "1")
    end
  end
end
