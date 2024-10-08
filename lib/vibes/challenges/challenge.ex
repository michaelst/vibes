defmodule Vibes.Challenges.Challenge do
  use Vibes.Schema
  import Ecto.Changeset

  @primary_key {:id, UXID, autogenerate: true, prefix: "chal"}
  schema "challenges" do
    field :title, :string
    field :subtitle, :string
    field :tracks_per_user, :integer
    field :status, Ecto.Enum, values: [:active, :reveal, :rate, :vibe_check, :final]
    field :submission_due_date, :utc_datetime
    field :rating_due_date, :utc_datetime

    field :artwork_url, :string

    belongs_to :submitted_by_user, Vibes.Users.User

    timestamps()
  end

  @doc false
  def changeset(struct \\ %__MODULE__{}, attrs) do
    struct
    |> cast(attrs, [:title, :subtitle, :tracks_per_user, :status])
    |> validate_required([:title, :subtitle, :tracks_per_user, :status])
  end
end
