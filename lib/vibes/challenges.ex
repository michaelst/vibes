defmodule Vibes.Challenges do
  import Ecto.Query

  alias Vibes.Challenges.Challenge
  alias Vibes.Challenges.Rating
  alias Vibes.Challenges.Submission
  alias Vibes.Repo

  def current_challenge() do
    Repo.one(from c in Challenge, where: c.status in ["active", "reveal", "vibe-check"])
  end

  def current_challenge(status) do
    Repo.one(from c in Challenge, where: c.status == ^status)
  end

  def get_challenge(id) do
    Repo.get!(Challenge, id)
  end

  def get_challenges() do
    Repo.all(from c in Challenge, order_by: [desc: c.inserted_at])
  end

  def get_submissions(challenge_id, user_id) do
    query =
      from s in Submission,
        where: s.challenge_id == ^challenge_id and s.user_id == ^user_id,
        preload: [:track, :ratings]

    Repo.all(query)
  end

  def get_submissions(challenge_id) do
    query =
      from s in Submission,
        where: s.challenge_id == ^challenge_id,
        order_by: s.revealed_at,
        preload: [:user, :track, :ratings]

    Repo.all(query)
  end

  def get_submission(id) do
    Repo.get!(Submission, id) |> Repo.preload(:track)
  end

  def submit_track(challenge, user, track) do
    query =
      from s in Submission,
        where: s.challenge_id == ^challenge.id and s.user_id == ^user.id,
        select: max(s.order)

    # defaults to negative 1 as this is 0 index based
    max = Repo.one(query) || -1

    with {:ok, track} <- Vibes.Music.insert_track(track) do
      %{challenge: challenge, user: user, track: track, order: max + 1}
      |> Submission.create_changeset()
      |> Repo.insert()
    end
  end

  def remove_submission(submission) do
    Repo.delete(submission)
  end

  def save_order(submissions, user) do
    query = from s in Submission, where: s.user_id == ^user.id
    Repo.update_all(query, set: [order: nil])

    submissions
    |> Enum.with_index()
    |> Enum.map(fn {submission, index} ->
      submission
      |> Submission.update_changeset(%{order: index})
      |> Ecto.Changeset.force_change(:order, index)
      |> Repo.update!()
    end)
  end

  def save_ratings(submissions, user) do
    query = from s in Submission, where: s.user_id == ^user.id
    Repo.update_all(query, set: [order: nil])

    ratings =
      submissions
      |> Enum.with_index()
      |> Enum.map(fn {submission, index} ->
        %{
          id: UXID.generate!(prefix: "rat"),
          rating: index + 1,
          user_id: user.id,
          submission_id: submission.id,
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    Repo.insert_all(Rating, ratings,
      on_conflict: {:replace, [:rating, :updated_at]},
      conflict_target: [:user_id, :submission_id]
    )
  end

  def reveal_submission(challenge_id) do
    query =
      from s in Submission,
        join: c in assoc(s, :challenge),
        where: s.challenge_id == ^challenge_id and is_nil(s.revealed_at),
        order_by: [s.order, {:desc, c.submitted_by_user_id == s.user_id}],
        limit: 1

    query
    |> Repo.one()
    |> Submission.update_changeset(%{revealed_at: DateTime.utc_now()})
    |> Repo.update!()
  end

  def update_submission(submission, attrs) do
    submission
    |> Submission.update_changeset(attrs)
    |> Repo.update()
  end
end
