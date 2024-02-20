defmodule VibesWeb.Live.VibeCheck do
  use VibesWeb, :live_view

  def mount(_params, _session, socket) do
    challenge = Vibes.Challenges.current_challenge("vibe-check")
    submissions = Vibes.Challenges.get_submissions(challenge.id)
    {:ok, assign(socket, challenge: challenge, submissions: submissions)}
  rescue
    _error -> {:ok, push_navigate(socket, to: ~p"/")}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 mb-8">
      <div class="mx-auto max-w-7xl px-6 lg:px-8">
        <div class="mx-auto max-w-2xl text-center">
          <img src={@challenge.artwork_url} class="my-6 mx-auto h-[300px]" />
          <div :if={@challenge.status == "reveal"} class="mt-8">
            <button
              :if={Enum.any?(@submissions, &is_nil(&1.revealed_at))}
              phx-click="reveal"
              class="rounded-md bg-indigo-500 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-400 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500"
            >
              Reveal next song
            </button>
          </div>
        </div>
      </div>
    </div>
    <ul class="divide-y divide-gray-800" id={@challenge.id}>
      <li
        :for={submission <- @submissions}
        :if={not is_nil(submission.revealed_at)}
        id={submission.id}
        class="flex justify-between items-center gap-x-6 py-5"
      >
        <div class="flex min-w-0 gap-x-4">
          <img class="h-12 w-12 flex-none bg-gray-800" src={submission.track.artwork_url} />
          <div class="min-w-0 flex-auto">
            <p class="text-sm font-semibold leading-6 text-white">
              <%= submission.track.name %>
              <.link href={submission.youtube_url} target="_blank">
                <img src={~p"/images/youtube.svg"} class="h-6 w-6 inline" />
              </.link>
            </p>
            <p class="mt-1 truncate text-xs leading-5 text-gray-400">
              <%= submission.track.artist %>
            </p>
          </div>
        </div>
        <div class="text-gray-300 text-sm">
          <%= submission.user.name %>
        </div>
      </li>
    </ul>
    """
  end

  def handle_event("reveal", _params, socket) do
    submission = Vibes.Challenges.reveal_submission(socket.assigns.challenge.id)
    {:noreply, push_navigate(socket, to: ~p"/reveal/#{submission.id}")}
  end
end
