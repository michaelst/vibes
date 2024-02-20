defmodule Vibes.Repo.Migrations.Ratings do
  use Ecto.Migration

  def change() do
    create table(:ratings) do
      add :user_id, references(:users)
      add :submission_id, references(:submissions)
      add :rating, :integer

      timestamps()
    end

    create unique_index(:ratings, [:user_id, :submission_id])
  end
end
