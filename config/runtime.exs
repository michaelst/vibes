import Config

Dotenv.load!()

defmodule Secret do
  def read!(name, non_prod_default \\ nil) do
    if config_env() == :prod do
      File.read!("/etc/secrets/" <> name)
    else
      System.get_env(name, non_prod_default)
    end
  end
end

config :vibes, Vibes.OAuth2.Spotify,
  client_id: System.get_env("SPOTIFY_CLIENT_ID"),
  client_secret: Secret.read!("SPOTIFY_CLIENT_SECRET")

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :vibes, Vibes.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :vibes, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :vibes, VibesWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base,
    server: true
end
