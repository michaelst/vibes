import Config

# Configure your database
config :vibes, Vibes.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "vibes_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.
config :vibes, VibesWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {0, 0, 0, 0}, port: 4000],
  url: [host: "michaels-macbook.local", port: 4000, scheme: "http"],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "rS9Pa30QkBCPtA0v5sb8868wlsJgqUwWd1Mgjye2aCpZYO8Wf4DuTTLP4aOE1XWw",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:vibes, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:vibes, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :vibes, VibesWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/vibes_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :vibes, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Include HEEx debug annotations as HTML comments in rendered markup
config :phoenix_live_view, :debug_heex_annotations, true
