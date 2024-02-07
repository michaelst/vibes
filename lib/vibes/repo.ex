defmodule Vibes.Repo do
  use Ecto.Repo,
    otp_app: :vibes,
    adapter: Ecto.Adapters.Postgres
end
