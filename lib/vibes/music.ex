defmodule Vibes.Music do
  alias Vibes.Music.Track
  alias Vibes.Repo

  def track_search(token, query) do
    {:ok, %{body: body}} = token |> Spotify.client() |> Spotify.track_search(query)

    Enum.map(body["tracks"]["items"], fn item ->
      {item["id"],
       %{
         artist: item["artists"] |> Enum.map(& &1["name"]) |> Enum.join(", "),
         artwork_url: item["album"]["images"] |> List.last() |> Map.get("url"),
         name: item["name"],
         spotify_id: item["id"]
       }}
    end)
    |> Map.new()
  end

  def insert_track(attrs) do
    %Track{}
    |> Track.changeset(attrs)
    |> Repo.insert(
      on_conflict: [set: [spotify_id: attrs.spotify_id]],
      conflict_target: :spotify_id,
      returning: [:id]
    )
  end
end
