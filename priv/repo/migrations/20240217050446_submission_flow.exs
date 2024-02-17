defmodule Vibes.Repo.Migrations.SubmissionFlow do
  use Ecto.Migration

  def change() do
    alter table(:submissions) do
      add :youtube_url, :string
      add :revealed_at, :utc_datetime
    end

    alter table(:challenges) do
      add :submitted_by_user_id, references(:users)
    end
  end
end
