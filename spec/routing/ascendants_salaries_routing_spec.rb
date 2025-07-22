require "rails_helper"

RSpec.describe AscendantsSalariesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/ascendants_salaries").to route_to("ascendants_salaries#index")
    end

    it "routes to #new" do
      expect(get: "/ascendants_salaries/new").to route_to("ascendants_salaries#new")
    end

    it "routes to #show" do
      expect(get: "/ascendants_salaries/1").to route_to("ascendants_salaries#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/ascendants_salaries/1/edit").to route_to("ascendants_salaries#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/ascendants_salaries").to route_to("ascendants_salaries#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/ascendants_salaries/1").to route_to("ascendants_salaries#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/ascendants_salaries/1").to route_to("ascendants_salaries#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/ascendants_salaries/1").to route_to("ascendants_salaries#destroy", id: "1")
    end
  end
end
