defmodule Vibes.Repo.Migrations.RatingsRevealedAt do
  use Ecto.Migration

  def change() do
    alter table(:submissions) do
      add :ratings_revealed_at, :utc_datetime
    end
  end
end
