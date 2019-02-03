# frozen_string_literal: true

require "rails_helper"

RSpec.describe "errors", type: :request do
  describe "bad_request" do
    it "renders" do
      get "/400"
      expect(response.code).to eq "400"
      expect(response).to render_template(:bad_request)
    end
    context "json" do
      it "returns json" do
        get "/400", headers: json_headers
        expect(response.code).to eq "400"
        expect(JSON.parse(response.body).is_a?(Hash)).to be_truthy
      end
    end
  end

  describe "unauthorized" do
    it "renders" do
      get "/401"
      expect(response.code).to eq "401"
      expect(response).to render_template(:unauthorized)
    end
    context "json" do
      it "returns json" do
        get "/401", headers: json_headers
        expect(response.code).to eq "401"
        expect(JSON.parse(response.body).is_a?(Hash)).to be_truthy
      end
    end
  end

  describe "not_found" do
    it "renders" do
      get "/404"
      expect(response.code).to eq "404"
      expect(response).to render_template(:not_found)
    end
    context "json" do
      it "returns json" do
        get "/404", headers: json_headers
        expect(response.code).to eq "404"
        expect(JSON.parse(response.body).is_a?(Hash)).to be_truthy
      end
    end
  end

  describe "unprocessable_entity" do
    it "renders" do
      get "/422"
      expect(response.code).to eq "422"
      expect(response).to render_template(:unprocessable_entity)
    end
    context "json" do
      it "returns json" do
        get "/422", headers: json_headers
        expect(response.code).to eq "422"
        expect(JSON.parse(response.body).is_a?(Hash)).to be_truthy
      end
    end
  end

  describe "server_error" do
    it "renders" do
      get "/500"
      expect(response.code).to eq "500"
      expect(response).to render_template(:server_error)
    end
    context "json" do
      it "returns json" do
        get "/500", headers: json_headers
        expect(response.code).to eq "500"
        expect(JSON.parse(response.body).is_a?(Hash)).to be_truthy
      end
    end
  end
end
