defmodule Vibes.OAuth2.Spotify do
  def client(strategy \\ OAuth2.Strategy.AuthCode) do
    OAuth2.Client.new(
      strategy: strategy,
      client_id: Application.get_env(:vibes, __MODULE__)[:client_id],
      client_secret: Application.get_env(:vibes, __MODULE__)[:client_secret],
      redirect_uri: VibesWeb.Endpoint.url() <> "/auth/callback",
      site: "https://api.spotify.com",
      authorize_url: "https://accounts.spotify.com/authorize",
      token_url: "https://accounts.spotify.com/api/token"
    )
    |> OAuth2.Client.put_serializer("application/json", Jason)
  end

  def authorize_url!() do
    OAuth2.Client.authorize_url!(client(), scope: "user-read-private streaming")
  end

  def get_app_token(params \\ [], headers \\ [], opts \\ []) do
    OAuth2.Client.get_token(
      client(OAuth2.Strategy.ClientCredentials),
      Keyword.put(params, :auth_scheme, "request_body"),
      headers,
      opts
    )
  end

  def get_user_token(params \\ [], headers \\ [], opts \\ []) do
    OAuth2.Client.get_token(
      client(),
      Keyword.put(params, :auth_scheme, "request_body"),
      headers,
      opts
    )
  end

  def refresh_user_token(refresh_token) do
    OAuth2.Client.get_token(
      client(OAuth2.Strategy.Refresh),
      refresh_token: refresh_token
    )
  end
end
