require "rails_helper"

RSpec.describe BaseReversionsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/base_reversions").to route_to("base_reversions#index")
    end

    it "routes to #new" do
      expect(get: "/base_reversions/new").to route_to("base_reversions#new")
    end

    it "routes to #show" do
      expect(get: "/base_reversions/1").to route_to("base_reversions#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/base_reversions/1/edit").to route_to("base_reversions#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/base_reversions").to route_to("base_reversions#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/base_reversions/1").to route_to("base_reversions#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/base_reversions/1").to route_to("base_reversions#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/base_reversions/1").to route_to("base_reversions#destroy", id: "1")
    end
  end
end
