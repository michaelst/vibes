defmodule VibesWeb.Live.VibeCheck do
  use VibesWeb, :live_view

  alias VibesWeb.Components.Live.Submission

  def mount(_params, _session, socket) do
    challenge = Vibes.Challenges.current_challenge("vibe-check")
    submissions = submissions(challenge)
    {:ok, assign(socket, challenge: challenge, submissions: submissions)}
  rescue
    _error -> {:ok, assign(socket, challenge: nil)}
  end

  def render(assigns) do
    ~H"""
    <div :if={@challenge}>
      <div class="bg-gray-900 mb-8">
        <div class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="mx-auto max-w-2xl text-center">
            <img src={@challenge.artwork_url} class="my-6 mx-auto h-[300px]" />
            <div class="mt-8">
              <button
                :if={Enum.any?(@submissions, &is_nil(&1.ratings_revealed_at))}
                phx-click="reveal"
                class="rounded-md bg-indigo-500 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-400 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500"
              >
                Reveal ratings for next song
              </button>
            </div>
          </div>
        </div>
      </div>
      <ul class="divide-y divide-gray-800 max-w-2xl mx-auto" id={@challenge.id}>
        <Submission.render
          :for={submission <- @submissions}
          submission={submission}
          challenge={@challenge}
        />
      </ul>
    </div>
    """
  end

  def handle_event("reveal", _params, socket) do
    submission = Vibes.Challenges.reveal_rating(socket.assigns.challenge.id)
    {:noreply, push_navigate(socket, to: ~p"/rating-reveal/#{submission.id}")}
  end

  defp submissions(challenge) do
    submissions = Vibes.Challenges.get_all_submissions(challenge.id)
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
              Enum.reduce(submission.ratings, 0, fn rating, acc -> acc + rating.rating end) /
                number

            Map.put(submission, :rating, average_rating)
        end
    end)
    |> Enum.sort_by(
      &{
        &1.rating,
        DateTime.to_unix(&1.revealed_at),
        challenge.submitted_by_user_id == &1.user_id
      }
    )
    |> rank_sumbmissions()
  end

  defp rank_sumbmissions(submissions) do
    submissions
    |> Enum.group_by(& &1.rating)
    |> Enum.sort_by(fn {rating, _submission} -> rating end)
    |> Enum.reduce({[], 1}, fn {_rating, submissions}, {acc, rank} ->
      submissions = Enum.map(submissions, fn submission -> Map.put(submission, :rank, rank) end)
      {acc ++ submissions, rank + length(submissions)}
    end)
    |> elem(0)
  end
end
