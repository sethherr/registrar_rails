# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "sluggable" do
  let(:model_sym) { subject.class.name.underscore.to_sym }
  let(:instance) { FactoryGirl.create model_sym }

  it "has callback for set_slug" do
    expect(subject.class._validation_callbacks.select { |cb| cb.kind.eql?(:before) }
      .map(&:raw_filter).include?(:set_slug)).to be_truthy
  end

  describe "slugify" do
    it "slugifies the thing we want" do
      expect(subject.class.slugify("Universal Health Care ")).to eq("universal_health_care")
    end
    it "removes double spaces" do
      expect(subject.class.slugify("  V2 Bike Issue - pedal / cranks")).to eq("v2_bike_issue_pedal_cranks")
    end
    it "strips special characters" do
      expect(subject.class.slugify("party-palaces' hause")).to eq("party_palaces_hause")
    end
    it "handles dashed things" do
      expect(subject.class.slugify("Cool -- A sweet change")).to eq("cool_a_sweet_change")
    end
    it "removes parentheses and what's inside them" do
      expect(subject.class.slugify("As Soon As Possible Party (ASAPP) ")).to eq("as_soon_as_possible_party")
    end
    it "returns without periods" do
      expect(subject.class.slugify("Washington D.C.")).to eq("washington_dc")
    end
    it "returns nil if given nil" do
      expect(subject.class.slugify(nil)).to be_nil
    end
  end

  describe "friendly_find" do
    context "integer_slug" do
      it "finds integers" do
        n = rand(0..15)
        expect(subject.class).to receive(:find).with(n)
        subject.class.friendly_find(n)
      end
    end

    context "not integer slug" do
      it "finds by the slug" do
        n = "foo"
        allow(subject.class).to receive(:slugify) { "bar" }
        expect(subject.class).to receive(:find_by_slug).with("bar")
        subject.class.friendly_find(n)
      end
    end

    context "bang method vs non-bang" do
      it "returns nil or raises" do
        expect(subject.class.friendly_find("666-party")).to be_nil
        expect do
          subject.class.friendly_find!("666-party")
        end.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
