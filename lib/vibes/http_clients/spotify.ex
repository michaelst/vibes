defmodule Spotify do
  def client(user) do
    {:ok, %{token: %{access_token: token}}} =
      Vibes.OAuth2.Spotify.refresh_user_token(user.spotify_refresh_token)

    middleware = [
      {Tesla.Middleware.BaseUrl, "https://api.spotify.com/v1"},
      {Tesla.Middleware.Headers, [{"authorization", "Bearer #{token}"}]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  def track_search(client, search) do
    query = URI.encode_query(q: search, type: "track")
    Tesla.get(client, "/search?#{query}")
  end
end
