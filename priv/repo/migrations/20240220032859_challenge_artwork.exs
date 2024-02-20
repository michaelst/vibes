defmodule Vibes.Repo.Migrations.ChallengeArtwork do
  use Ecto.Migration

  def change() do
    alter table(:challenges) do
      add :artwork_url, :string
    end
  end
end
