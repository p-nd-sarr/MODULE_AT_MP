require "rails_helper"

RSpec.describe Admin::DecesSalariesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/deces_salaries").to route_to("admin/deces_salaries#index")
    end

    it "routes to #new" do
      expect(get: "/admin/deces_salaries/new").to route_to("admin/deces_salaries#new")
    end

    it "routes to #show" do
      expect(get: "/admin/deces_salaries/1").to route_to("admin/deces_salaries#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/deces_salaries/1/edit").to route_to("admin/deces_salaries#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/deces_salaries").to route_to("admin/deces_salaries#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/deces_salaries/1").to route_to("admin/deces_salaries#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/deces_salaries/1").to route_to("admin/deces_salaries#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/deces_salaries/1").to route_to("admin/deces_salaries#destroy", id: "1")
    end
  end
end
