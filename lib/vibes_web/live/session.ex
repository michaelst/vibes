defmodule VibesWeb.Live.Session do
  use VibesWeb, :live_view

  def mount(_params, _session, socket) do
    challenge = Vibes.Challenges.current_challenge()
    submissions = Vibes.Challenges.get_submissions(challenge.id)
    {:ok, assign(socket, challenge: challenge, submissions: submissions)}
  rescue
    _error -> {:ok, push_navigate(socket, to: ~p"/")}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 mb-8">
      <div class="mx-auto max-w-7xl px-6 lg:px-8">
        <div class="mx-auto max-w-2xl sm:text-center">
          <h2 class="text-base font-semibold leading-7 text-indigo-400">Current Challenge</h2>
          <p class="mt-4 text-3xl font-bold tracking-tight text-white sm:text-4xl">
            <%= @challenge.title %>
          </p>
          <p class="mt-2 text-lg leading-8 text-gray-300">
            <%= @challenge.subtitle %>
          </p>
          <div :if={@challenge.status == "reveal"} class="mt-8">
            <button
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
            <p class="text-sm font-semibold leading-6 text-white"><%= submission.track.name %></p>
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
