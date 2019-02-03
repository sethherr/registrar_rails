# frozen_string_literal: true

shared_context :logged_in_as_user do
  let(:user) { FactoryBot.create(:user) }
  before { sign_in user }
end

shared_context :logged_in_as_staff do
  let(:user) { FactoryBot.create(:user_staff) }
  before { sign_in user }
end

shared_context :logged_in_as_manager do
  let(:user) { FactoryBot.create(:user_manager) }
  before { sign_in user }
end

shared_context :logged_in_as_admin do
  let(:user) { FactoryBot.create(:user_admin) }
  before { sign_in user }
end

shared_context :api_v1_request_spec do
  let(:user) { FactoryBot.create(:user) }
  let(:authorization_headers) { json_headers.merge("Authorization" => "Bearer #{user.api_key}") }

  def target_links(url_path)
    {
      self: "#{ENV['BASE_DOMAIN']}#{url_path}",
      next: nil,
      prev: nil,
      first: "#{ENV['BASE_DOMAIN']}#{url_path}",
      last: "#{ENV['BASE_DOMAIN']}#{url_path}?page=1"
    }.as_json
  end
end

# Request spec helpers that are included in all request specs via Rspec.configure (rails_helper)
module RequestSpecHelpers
  def json_headers
    { "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" }
  end

  def json_result
    r = JSON.parse(response.body)
    r.is_a?(Hash) ? r.with_indifferent_access : r
  end
end
