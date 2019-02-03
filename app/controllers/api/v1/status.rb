# frozen_string_literal: true

class API::V1::Status < API::Base
  resource :status do
    desc "Current System status"
    get "/" do
      {
        current: "live"
      }
    end
  end
end
