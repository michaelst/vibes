defmodule Vibes.Repo.Migrations.SubmissionsSetup do
  use Ecto.Migration

  def change() do
    create table(:challenges) do
      add :title, :text, null: false
      add :subtitle, :text, null: false
      add :tracks_per_user, :integer, null: false
      add :status, :text, null: false

      timestamps()
    end

    create table(:tracks) do
      add :name, :text, null: false
      add :artist, :text, null: false
      add :artwork_url, :text, null: false
      add :spotify_id, :text, null: false

      timestamps()
    end

    create unique_index(:tracks, [:spotify_id])

    create table(:submissions) do
      add :order, :integer
      add :challenge_id, references(:challenges), null: false
      add :user_id, references(:users), null: false
      add :track_id, references(:tracks), null: false

      timestamps()
    end

    create unique_index(:submissions, [:challenge_id, :track_id])
  end
end
