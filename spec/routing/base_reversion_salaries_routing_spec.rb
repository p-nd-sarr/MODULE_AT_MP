require "rails_helper"

RSpec.describe BaseReversionSalariesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/base_reversion_salaries").to route_to("base_reversion_salaries#index")
    end

    it "routes to #new" do
      expect(get: "/base_reversion_salaries/new").to route_to("base_reversion_salaries#new")
    end

    it "routes to #show" do
      expect(get: "/base_reversion_salaries/1").to route_to("base_reversion_salaries#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/base_reversion_salaries/1/edit").to route_to("base_reversion_salaries#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/base_reversion_salaries").to route_to("base_reversion_salaries#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/base_reversion_salaries/1").to route_to("base_reversion_salaries#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/base_reversion_salaries/1").to route_to("base_reversion_salaries#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/base_reversion_salaries/1").to route_to("base_reversion_salaries#destroy", id: "1")
    end
  end
end
