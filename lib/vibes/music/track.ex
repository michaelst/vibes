defmodule Vibes.Music.Track do
  use Vibes.Schema
  import Ecto.Changeset

  @primary_key {:id, UXID, autogenerate: true, prefix: "tk"}
  schema "tracks" do
    field :name, :string
    field :artist, :string
    field :artwork_url, :string
    field :spotify_id, :string

    timestamps()
  end

  @doc false
  def changeset(track, attrs) do
    track
    |> cast(attrs, [:name, :artist, :artwork_url, :spotify_id])
    |> validate_required([:name, :artist, :artwork_url, :spotify_id])
    |> unique_constraint(:spotify_id)
  end
end
