require "rails_helper"

RSpec.describe Admin::IcmModifierInfoPersonellesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/icm_modifier_info_personelles").to route_to("admin/icm_modifier_info_personelles#index")
    end

    it "routes to #new" do
      expect(get: "/admin/icm_modifier_info_personelles/new").to route_to("admin/icm_modifier_info_personelles#new")
    end

    it "routes to #show" do
      expect(get: "/admin/icm_modifier_info_personelles/1").to route_to("admin/icm_modifier_info_personelles#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/icm_modifier_info_personelles/1/edit").to route_to("admin/icm_modifier_info_personelles#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/icm_modifier_info_personelles").to route_to("admin/icm_modifier_info_personelles#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/icm_modifier_info_personelles/1").to route_to("admin/icm_modifier_info_personelles#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/icm_modifier_info_personelles/1").to route_to("admin/icm_modifier_info_personelles#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/icm_modifier_info_personelles/1").to route_to("admin/icm_modifier_info_personelles#destroy", id: "1")
    end
  end
end
