# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/documentation", type: :request do
  describe "index" do
    it "redirects" do
      get "/documentation"
      expect(response).to redirect_to(api_v1_documentation_index_path)
    end
  end

  describe "v1" do
    it "renders" do
      get "/documentation/api_v1"
      expect(response.code).to eq "200"
      expect(response).to render_template("documentation/api_v1")
    end
  end
end
