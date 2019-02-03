# frozen_string_literal: true

class API::V1::User < API::Base
  resource :user do
    desc "Current User"
    get "/" do
      {
        current_user: {
          info: current_user && "nothing here"
        }
      }
    end
  end
end
