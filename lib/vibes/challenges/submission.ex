defmodule Vibes.Challenges.Submission do
  use Vibes.Schema
  import Ecto.Changeset

  @primary_key {:id, UXID, autogenerate: true, prefix: "sub"}
  schema "submissions" do
    field :order, :integer
    field :youtube_url, :string
    field :revealed_at, :utc_datetime
    field :ratings_revealed_at, :utc_datetime
    field :why, :string

    belongs_to :challenge, Vibes.Challenges.Challenge
    belongs_to :track, Vibes.Music.Track
    belongs_to :user, Vibes.Users.User

    has_many :ratings, Vibes.Challenges.Rating

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
    |> cast(attrs, [:order, :why, :youtube_url, :revealed_at, :ratings_revealed_at])
    |> validate_format(:youtube_url, ~r{^https://www.youtube.com/watch\?v=.*$},
      message: "must be a YouTube watch URL"
    )
  end

  def parse_youtube_url(url) when is_binary(url) do
    regex =
      ~r/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/

    case Regex.run(regex, url) do
      [_link, id] -> "https://www.youtube.com/watch?v=#{id}"
      _no_match -> url
    end
  end

  def parse_youtube_url(url), do: url
end
