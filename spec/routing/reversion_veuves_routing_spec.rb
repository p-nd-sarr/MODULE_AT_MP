require "rails_helper"

RSpec.describe ReversionVeuvesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/reversion_veuves").to route_to("reversion_veuves#index")
    end

    it "routes to #new" do
      expect(get: "/reversion_veuves/new").to route_to("reversion_veuves#new")
    end

    it "routes to #show" do
      expect(get: "/reversion_veuves/1").to route_to("reversion_veuves#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/reversion_veuves/1/edit").to route_to("reversion_veuves#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/reversion_veuves").to route_to("reversion_veuves#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/reversion_veuves/1").to route_to("reversion_veuves#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/reversion_veuves/1").to route_to("reversion_veuves#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/reversion_veuves/1").to route_to("reversion_veuves#destroy", id: "1")
    end
  end
end
