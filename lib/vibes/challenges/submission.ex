defmodule Vibes.Challenges.Submission do
  use Vibes.Schema
  import Ecto.Changeset

  @primary_key {:id, UXID, autogenerate: true, prefix: "sub"}
  schema "submissions" do
    field :order, :integer

    belongs_to :challenge, Vibes.Challenges.Challenge
    belongs_to :track, Vibes.Music.Track
    belongs_to :user, Vibes.Users.User

    timestamps()
  end

  @doc false
  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:order])
    |> put_assoc(:challenge, attrs.challenge)
    |> put_assoc(:track, attrs.track)
    |> put_assoc(:user, attrs.user)
    |> foreign_key_constraint(:challenge_id)
    |> foreign_key_constraint(:track_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:challenge_id, :track_id])
  end

  def update_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:order])
  end
end