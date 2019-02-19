# frozen_string_literal: true

class API::V1::RootV1 < API::Base
  format :json
  version "v1", using: :path

  helpers do
    def paginate(path)
      {
        self: "#{ENV['BASE_DOMAIN']}/api/v1/#{path}" + (@page == 1 ? "" : "?page=#{@page}"),
        first: "#{ENV['BASE_DOMAIN']}/api/v1/#{path}",
        last: "#{ENV['BASE_DOMAIN']}/api/v1/#{path}?page=#{@paginated_obj.total_pages}",
        prev: @paginated_obj.prev_page && "#{ENV['BASE_DOMAIN']}/api/v1/#{path}?page=#{@paginated_obj.prev_page}",
        next: @paginated_obj.next_page && "#{ENV['BASE_DOMAIN']}/api/v1/#{path}?page=#{@paginated_obj.next_page}"
      }
    end

    def ensure_current_user!
      current_user # Just to make the method more descriptive
    end

    def current_user
      @current_user ||= authenticate!
    rescue => e
      error!({ error: e.message }, 401)
    end

    def authenticate!
      token = (request.headers["Authorization"] || request.headers["authorization"])&.split(" ")&.last
      user = User.where(api_key: token).first
      return user if user&.active_for_authentication?
      raise(StandardError, "Failed to login")
    end
  end

  mount API::V1::Status
  mount API::V1::User
  mount API::V1::Registrations

  add_swagger_documentation \
    host: ENV["BASE_DOMAIN"].gsub(/https?.../, ""),
    doc_version: "v1",
    mount_path: "/swagger_doc",
    hide_documentation_path: true,
    info: {
      title: "Registrar API V1",
      description: "Register everything!"
    }

  route :any, "*path" do
    error!({ error: "Unable to find endpoint" }, 404)
  end
end
