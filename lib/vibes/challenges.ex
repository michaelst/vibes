defmodule Vibes.Challenges do
  import Ecto.Query

  alias Vibes.Challenges.Challenge
  alias Vibes.Challenges.Submission
  alias Vibes.Repo

  def current_challenge() do
    Repo.one(from c in Challenge, where: c.status == "active")
  end

  def get_challenge(id) do
    Repo.get!(Challenge, id)
  end

  def get_submissions(challenge_id, user_id) do
    query =
      from s in Submission,
        where: s.challenge_id == ^challenge_id and s.user_id == ^user_id,
        order_by: s.order,
        preload: :track

    Repo.all(query)
  end

  def submit_track(challenge, user, track) do
    query =
      from s in Submission,
        where: s.challenge_id == ^challenge.id and s.user_id == ^user.id,
        select: max(s.order)

    max = Repo.one(query)

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
end
