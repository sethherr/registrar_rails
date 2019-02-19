# frozen_string_literal: true

class API::V1::User < API::Base
  resource :user do
    desc "Current User"
    get "/" do
      {
        current_user: {
          name: current_user&.display_name,
          authorizations: current_user.user_integrations.pluck(:provider)
        }
      }
    end
  end
end
