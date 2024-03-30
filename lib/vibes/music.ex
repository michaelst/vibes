defmodule Vibes.Music do
  import Ecto.Query

  alias Vibes.Music.Track
  alias Vibes.Repo
  alias Vibes.Users.User

  def track_search(token, query) do
    {:ok, %{body: body}} = token |> Spotify.client() |> Spotify.track_search(query)

    Enum.map(body["tracks"]["items"], fn item ->
      {item["id"],
       %{
         artist: item["artists"] |> Enum.map(& &1["name"]) |> Enum.join(", "),
         artwork_url: item["album"]["images"] |> List.last() |> Map.get("url"),
         name: item["name"],
         spotify_id: item["id"],
         preview_url: item["preview_url"]
       }}
    end)
    |> Map.new()
  end

  def insert_track(attrs) do
    %Track{}
    |> Track.changeset(attrs)
    |> Repo.insert(
      on_conflict: {:replace, [:preview_url, :updated_at]},
      conflict_target: :spotify_id,
      returning: [:id]
    )
  end

  def sync_preview_urls() do
    query = from User, limit: 1
    user = Repo.one(query)

    {:ok, %{token: %{access_token: token}}} =
      Vibes.OAuth2.Spotify.refresh_user_token(user.spotify_refresh_token)

    client = Spotify.client(token)
    query = from t in Track, where: is_nil(t.preview_url), select: t.spotify_id

    query
    |> Repo.all()
    |> Enum.map(&Spotify.get_track(client, &1))
    |> Enum.map(fn {:ok, %{body: body}} ->
      insert_track(%{
        artist: body["artists"] |> Enum.map(& &1["name"]) |> Enum.join(", "),
        artwork_url: body["album"]["images"] |> List.last() |> Map.get("url"),
        name: body["name"],
        spotify_id: body["id"],
        preview_url: body["preview_url"]
      })
    end)
  end
end
