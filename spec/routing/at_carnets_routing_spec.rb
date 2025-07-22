require "rails_helper"

RSpec.describe AtCarnetsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/at_carnets").to route_to("at_carnets#index")
    end

    it "routes to #new" do
      expect(get: "/at_carnets/new").to route_to("at_carnets#new")
    end

    it "routes to #show" do
      expect(get: "/at_carnets/1").to route_to("at_carnets#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/at_carnets/1/edit").to route_to("at_carnets#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/at_carnets").to route_to("at_carnets#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/at_carnets/1").to route_to("at_carnets#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/at_carnets/1").to route_to("at_carnets#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/at_carnets/1").to route_to("at_carnets#destroy", id: "1")
    end
  end
end
