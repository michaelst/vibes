defmodule Vibes.Repo.Migrations.AddWhyToSubmission do
  use Ecto.Migration

  def change() do
    alter table(:submissions) do
      add :why, :text
    end
  end
end
