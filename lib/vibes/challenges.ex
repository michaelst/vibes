defmodule Vibes.Challenges do
  import Ecto.Query

  alias Vibes.Challenges.Challenge
  alias Vibes.Challenges.Rating
  alias Vibes.Challenges.Submission
  alias Vibes.Repo

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

  def get_all_submissions(challenge) do
    query =
      from s in Submission,
        join: c in assoc(s, :challenge),
        where: s.challenge_id == ^challenge.id,
        preload: [:user, :track, ratings: :user]

    submissions = Repo.all(query)
    number_of_submissions = length(submissions)

    submissions
    |> Enum.map(fn
      %{ratings_revealed_at: nil} = submission ->
        Map.put(submission, :rating, nil)

      submission ->
        # if anyone has rated the song last and no one rated it first, the song is vetoed
        with true <- Enum.any?(submission.ratings, &(&1.rating == number_of_submissions)),
             false <- Enum.any?(submission.ratings, &(&1.rating == 1)) do
          Map.put(submission, :rating, number_of_submissions)
        else
          _not_vetoed ->
            number = length(submission.ratings)

            average_rating =
              Enum.reduce(submission.ratings, 0, fn rating, acc -> acc + rating.rating end)
              |> Kernel./(number)
              |> Float.round()
              |> trunc()

            Map.put(submission, :rating, average_rating)
        end
    end)
    |> Enum.sort_by(
      &{
        &1.rating,
        &1.revealed_at && DateTime.to_unix(&1.revealed_at),
        challenge.submitted_by_user_id == &1.user_id
      }
    )
    |> Enum.group_by(& &1.rating)
    |> Enum.sort_by(fn {rating, _submission} -> rating end)
    |> Enum.reduce({[], 1}, fn {_rating, submissions}, {acc, rank} ->
      submissions = Enum.map(submissions, fn submission -> Map.put(submission, :rank, rank) end)
      {acc ++ submissions, rank + length(submissions)}
    end)
    |> elem(0)
  end

  def get_submission(id) do
    Repo.get!(Submission, id) |> Repo.preload([:track, ratings: :user])
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
        where: s.challenge_id == ^challenge_id and is_nil(s.revealed_at),
        order_by: s.order,
        preload: [:challenge]

    query
    |> Repo.all()
    |> Enum.flat_map(fn submission ->
      number_of_copies = submission.challenge.tracks_per_user - submission.order
      Enum.map(0..number_of_copies, fn _ -> submission end)
    end)
    |> Enum.random()
    |> Submission.update_changeset(%{revealed_at: DateTime.utc_now()})
    |> Repo.update!()
  end

  def reveal_rating(challenge_id) do
    query =
      from s in Submission,
        join: c in assoc(s, :challenge),
        where: s.challenge_id == ^challenge_id and is_nil(s.ratings_revealed_at),
        order_by: [s.revealed_at, {:desc, c.submitted_by_user_id == s.user_id}],
        limit: 1

    query
    |> Repo.one()
    |> Submission.update_changeset(%{ratings_revealed_at: DateTime.utc_now()})
    |> Repo.update!()
  end

  def update_submission(submission, attrs) do
    submission
    |> Submission.update_changeset(attrs)
    |> Repo.update()
  end
end
