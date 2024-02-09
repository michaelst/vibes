import Config

config :vibes,
  ecto_repos: [Vibes.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

config :vibes, Vibes.Repo,
  migration_primary_key: [type: :text],
  migration_timestamps: [type: :utc_datetime]

# Configures the endpoint
config :vibes, VibesWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: VibesWeb.ErrorHTML, json: VibesWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Vibes.PubSub,
  live_view: [signing_salt: "vG0ZPrXz"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  vibes: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  vibes: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :oauth2, debug: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
