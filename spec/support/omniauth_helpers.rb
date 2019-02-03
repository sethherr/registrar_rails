# frozen_string_literal: true

shared_context :omniauth_helpers do
  let(:default_bike_index_auth_hash) do
    {
      provider: "bike_index",
      uid: "85",
      info: {
        nickname: "seth",
        bike_ids: [6, 35, 32], # Abbreviated list
        email: "seth@bikeindex.orgd",
        name: "Seth Herr",
        twitter: "bikeindex",
        secondary_emails: [],
        image: "https://files.bikeindex.org/uploads/Us/85/cross.jpg"
      },
      credentials: {
        token: "xxx",
        refresh_token: "zzzzz",
        expires_at: 1537731144,
        expires: true
      },
      extra: {
        raw_info: {
          id: "85",
          user: {
            username: "seth",
            name: "Seth Herr",
            email: "seth@bikeindex.orgd",
            twitter: "bikeindex",
            image: "https://files.bikeindex.org/uploads/Us/85/cross.jpg",
            confirmed: true
          },
          bike_ids: [6, 35, 32]
        }
      }
    }
  end
end
