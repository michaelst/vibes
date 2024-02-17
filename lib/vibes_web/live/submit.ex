defmodule VibesWeb.Live.Submit do
  use VibesWeb, :live_view

  def mount(_params, _session, socket) do
    challenge = Vibes.Challenges.current_challenge()

    {:ok, assign(socket, challenge: challenge, results: %{})}
  rescue
    _error -> {:ok, push_navigate(socket, to: ~p"/")}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 mb-8">
      <.link navigate={~p"/"} class="text-white">Back</.link>
      <div class="mx-auto max-w-7xl mt-4">
        <.form for={%{}} phx-change="search">
          <div class="mt-2">
            <input
              type="text"
              name="search"
              id="search"
              phx-debounce="500"
              class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
              placeholder="search for a song"
            />
          </div>
        </.form>
      </div>
    </div>
    <ul role="list" class="divide-y divide-gray-800">
      <li :for={{id, track} <- @results} class="flex justify-between items-center gap-x-6 py-5">
        <div class="flex min-w-0 gap-x-4">
          <img class="h-12 w-12 flex-none bg-gray-800" src={track.artwork_url} />
          <div class="min-w-0 flex-auto">
            <p class="text-sm font-semibold leading-6 text-white"><%= track.name %></p>
            <p class="mt-1 truncate text-xs leading-5 text-gray-400">
              <%= track.artist %>
            </p>
          </div>
        </div>
        <div>
          <button phx-click="add" phx-value-track={id} class="text-gray-400">
            Add
          </button>
        </div>
      </li>
    </ul>
    """
  end

  def handle_event("search", %{"search" => search}, socket) do
    results = Vibes.Music.track_search(socket.assigns.current_user, search)
    {:noreply, assign(socket, results: results)}
  end

  def handle_event("add", %{"track" => spotify_id}, socket) do
    track = Map.get(socket.assigns.results, spotify_id)

    case Vibes.Challenges.submit_track(
           socket.assigns.challenge,
           socket.assigns.current_user,
           track
         ) do
      {:ok, _submission} ->
        {:noreply, push_navigate(socket, to: ~p"/")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Unable to submit track")}
    end
  end
end
