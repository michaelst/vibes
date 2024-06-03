defmodule Vibes.Repo.Migrations.MakeSubtitleNullable do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      modify :subtitle, :string, null: true
    end
  end
end
