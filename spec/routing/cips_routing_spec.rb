require "rails_helper"

RSpec.describe CipsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/cips").to route_to("cips#index")
    end

    it "routes to #new" do
      expect(get: "/cips/new").to route_to("cips#new")
    end

    it "routes to #show" do
      expect(get: "/cips/1").to route_to("cips#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/cips/1/edit").to route_to("cips#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/cips").to route_to("cips#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/cips/1").to route_to("cips#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/cips/1").to route_to("cips#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/cips/1").to route_to("cips#destroy", id: "1")
    end
  end
end
