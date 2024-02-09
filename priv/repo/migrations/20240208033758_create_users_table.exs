defmodule Vibes.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change() do
    create table(:users) do
      add :name, :text
      add :spotify_id, :text
      add :spotify_refresh_token, :text

      timestamps()
    end

    create unique_index(:users, [:spotify_id])
  end
end
