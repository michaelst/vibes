defmodule VibesWeb.Live.RatingReveal do
  use VibesWeb, :live_view

  def mount(params, _session, socket) do
    challenge = Vibes.Challenges.current_challenge("vibe_check")
    submission = Vibes.Challenges.get_submission(params["id"])
    {:ok, assign(socket, challenge: challenge, submission: submission, show_ratings: false)}
  rescue
    _error -> {:ok, push_navigate(socket, to: ~p"/vibe-check")}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 mb-8">
      <div class="mx-auto max-w-5xl px-6 lg:px-8">
        <div class="mx-auto sm:text-center">
          <div>
            <p class="mt-4 text-3xl font-bold tracking-tight text-white sm:text-4xl">
              <%= @submission.track.name %>
            </p>
            <p class="mt-2 text-lg leading-8 text-gray-300">
              <%= @submission.track.artist %>
            </p>
            <p class="mt-4 text-md leading-8 text-gray-300">
              <span class="text-gray-500">Submitted by</span> <%= @submission.user.name %>
            </p>
          </div>

          <audio controls class="mx-auto my-4">
            <source src={@submission.track.preview_url} type="audio/mpeg" />
            Your browser does not support the audio element.
          </audio>

          <div :if={@show_ratings} class="mx-auto flex my-16">
            <div :for={rating <- @submission.ratings} class="mx-auto flex max-w-xs flex-col gap-y-4">
              <dt class="text-base leading-7 text-gray-400"><%= rating.user.name %></dt>
              <dd class="order-first text-3xl font-semibold tracking-tight text-white sm:text-5xl">
                <%= rating.rating %>
              </dd>
            </div>
          </div>

          <button
            :if={not @show_ratings}
            phx-click="show_ratings"
            class="mt-4 rounded-md bg-indigo-500 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-400 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500"
          >
            Show ratings
          </button>

          <div :if={@show_ratings} class="mt-8">
            <.link
              navigate={~p"/vibe-check"}
              class="rounded-md bg-indigo-500 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-400 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500"
            >
              Done
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("show_ratings", _params, socket) do
    {:noreply, assign(socket, :show_ratings, true)}
  end
end
