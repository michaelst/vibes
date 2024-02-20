defmodule Vibes.Challenges.Rating do
  use Vibes.Schema

  @primary_key {:id, UXID, autogenerate: true, prefix: "rat"}
  schema "ratings" do
    field :rating, :integer

    belongs_to :user, Vibes.Users.User
    belongs_to :submission, Vibes.Challenges.Submission

    timestamps()
  end
end
