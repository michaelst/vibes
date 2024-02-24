defmodule Vibes.Repo.Migrations.TrackPreviewUrl do
  use Ecto.Migration

  def change() do
    alter table(:tracks) do
      add :preview_url, :string
    end
  end
end
