defmodule VibesWeb.Live.Home do
  use VibesWeb, :live_view

  def mount(_params, _session, socket) do
    challenge = Vibes.Challenges.current_challenge()
    {:ok, assign(socket, challenge: challenge)}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 py-24">
      <div class="mx-auto max-w-7xl px-6 lg:px-8">
        <div class="mx-auto max-w-2xl sm:text-center">
          <h2 class="text-base font-semibold leading-7 text-indigo-400">Current Challenge</h2>
          <p class="mt-4 text-3xl font-bold tracking-tight text-white sm:text-4xl">
            <%= @challenge.title %>
          </p>
          <p class="mt-2 text-lg leading-8 text-gray-300">
            <%= @challenge.subtitle %>
          </p>
          <div class="mt-8">
            <.link
              href={~p"/challenges/#{@challenge.id}"}
              class="rounded-md bg-indigo-500 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-400 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500"
            >
              Submit your songs
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
