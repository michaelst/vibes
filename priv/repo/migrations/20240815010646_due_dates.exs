defmodule Vibes.Repo.Migrations.DueDates do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :submission_due_date, :utc_datetime
      add :rating_due_date, :utc_datetime
    end
  end
end
