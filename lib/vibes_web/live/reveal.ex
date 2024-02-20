defmodule VibesWeb.Live.Reveal do
  use VibesWeb, :live_view

  def mount(params, _session, socket) do
    challenge = Vibes.Challenges.current_challenge("reveal")
    submission = Vibes.Challenges.get_submission(params["id"])
    {:ok, assign(socket, challenge: challenge, submission: submission)}
  rescue
    _error -> {:ok, push_navigate(socket, to: ~p"/reveal")}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 mb-8">
      <div class="mx-auto max-w-7xl px-6 lg:px-8">
        <div class="mx-auto max-w-2xl sm:text-center">
          <p class="mt-4 text-3xl font-bold tracking-tight text-white sm:text-4xl">
            <%= @submission.track.name %>
          </p>
          <p class="mt-2 text-lg leading-8 text-gray-300">
            <%= @submission.track.artist %>
          </p>
          <iframe
            width="560"
            height="315"
            class="mt-8"
            src={String.replace(@submission.youtube_url, "watch?v=", "embed/")}
            title="YouTube video player"
            frameborder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
            allowfullscreen
          >
          </iframe>
          <div class="mt-8">
            <.link
              navigate={~p"/reveal"}
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
end
