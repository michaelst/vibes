defmodule Vibes.OAuth2.Spotify do
  use OAuth2.Strategy

  def client(strategy \\ OAuth2.Strategy.AuthCode) do
    OAuth2.Client.new(
      strategy: strategy,
      client_id: Application.get_env(:vibes, __MODULE__)[:client_id],
      client_secret: Application.get_env(:vibes, __MODULE__)[:client_secret],
      redirect_uri: VibesWeb.Endpoint.url() <> "/auth/callback",
      site: VibesWeb.Endpoint.url(),
      token_url: "https://accounts.spotify.com/api/token"
    )
    |> OAuth2.Client.put_serializer("application/json", Jason)
  end

  def authorize_url!() do
    OAuth2.Client.authorize_url!(client(), scope: "user,public_repo")
  end

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token!(params \\ [], headers \\ [], opts \\ []) do
    OAuth2.Client.get_token!(
      client(OAuth2.Strategy.ClientCredentials),
      Keyword.put(params, :auth_scheme, "request_body"),
      headers,
      opts
    )
  end

  def get_token(client, params, headers) do
    client
    |> put_header("accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
