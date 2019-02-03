# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "sortable_search_params" do
    before { controller.params = ActionController::Parameters.new(passed_params) }
    context "no sortable_search_params" do
      let(:passed_params) { { party: "stuff" } }
      it "returns an empty hash" do
        expect(sortable_search_params.to_unsafe_h).to eq({})
      end
    end
    context "direction, sort" do
      let(:passed_params) { { direction: "asc", sort: "stolen", party: "long" } }
      let(:target) { { direction: "asc", sort: "stolen" } }
      it "returns an empty hash" do
        expect(sortable_search_params.to_unsafe_h).to eq(target.as_json)
      end
    end
    context "direction, sort, search param, user_id" do
      let(:passed_params) { { direction: "asc", sort: "stolen", party: "long", search_stuff: "xxx", user_id: 21 } }
      let(:target) { { direction: "asc", sort: "stolen", search_stuff: "xxx", user_id: 21 } }
      it "returns an empty hash" do
        expect(sortable_search_params.to_unsafe_h).to eq(target.as_json)
      end
    end
  end

  describe "active_link" do
    context "match_controller" do
      let(:request) { double("request", url: new_admin_promo_code_path) }
      before { allow(helper).to receive(:request).and_return(request) }
      it "returns the link active with match_controller if on the controller" do
        expect(active_link("Organizations", new_admin_promo_code_path, class: "seeeeeeee", id: "something", match_controller: true))
          .to eq '<a class="seeeeeeee active" id="something" href="' + new_admin_promo_code_path + '">Organizations</a>'
      end
    end
  end

  describe "status_class" do
    it "is text-danger for inactive" do
      expect(status_class("inactive")).to eq "text-danger"
    end
    context "kiosk_room_membership_purchase" do
      let(:obj) { KioskRoomMembershipPurchase.new }
      it "is text-warning" do
        expect(status_class(obj)).to eq "text-warning"
      end
    end
  end
end
