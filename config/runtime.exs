import Config

if Config.config_env() == :dev, do: Dotenv.load!()

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
  client_id: Secret.read!("SPOTIFY_CLIENT_ID"),
  client_secret: Secret.read!("SPOTIFY_CLIENT_SECRET")

if config_env() == :prod do
  config :vibes, Vibes.Repo,
    ssl: true,
    ssl_opts: [
      verify: :verify_none
    ],
    database: "vibes",
    hostname: System.fetch_env!("DB_HOSTNAME"),
    username: System.fetch_env!("DB_USERNAME"),
    password: Secret.read!("DB_PASSWORD"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  host = System.get_env("PHX_HOST") || "ifyougetityougetit.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :vibes, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :vibes, VibesWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: Secret.read!("SECRET_KEY_BASE"),
    server: true
end
