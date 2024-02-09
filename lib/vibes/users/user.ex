defmodule Vibes.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, UXID, autogenerate: true, prefix: "usr"}
  schema "users" do
    field :name, :string
    field :spotify_id, :string
    field :spotify_refresh_token, :string

    timestamps()
  end

  @doc false
  def changeset(user \\ %__MODULE__{}, attrs) do
    user
    |> cast(attrs, [:name, :spotify_id, :spotify_refresh_token])
    |> validate_required([:name, :spotify_id, :spotify_refresh_token])
    |> unique_constraint(:spotify_id)
  end
end
