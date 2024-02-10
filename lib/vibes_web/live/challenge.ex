defmodule VibesWeb.Live.Challenge do
  use VibesWeb, :live_view

  def mount(params, _session, socket) do
    challenge = Vibes.Challenges.get_challenge(params["id"])
    submissions = Vibes.Challenges.get_submissions(challenge.id, socket.assigns.current_user.id)
    {:ok, assign(socket, challenge: challenge, submissions: submissions)}
  rescue
    _error -> {:ok, redirect(socket, to: ~p"/")}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 mb-8">
      <div class="mx-auto max-w-7xl px-6 lg:px-8">
        <div class="mx-auto max-w-2xl sm:text-center">
          <p class="mt-4 text-3xl font-bold tracking-tight text-white sm:text-4xl">
            <%= @challenge.title %>
          </p>
          <p class="mt-2 text-lg leading-8 text-gray-300">
            <%= @challenge.subtitle %>
          </p>
          <div :if={length(@submissions) < @challenge.tracks_per_user} class="mt-8">
            <.link
              href={~p"/challenges/#{@challenge.id}/submit"}
              class="rounded-md bg-indigo-500 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-400 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500"
            >
              Add song
            </.link>
          </div>
        </div>
      </div>
    </div>
    <ul phx-hook="Sortable" class="divide-y divide-gray-800" id={@challenge.id}>
      <li
        :for={submission <- @submissions}
        id={submission.id}
        class="flex justify-between gap-x-6 py-5"
      >
        <div class="flex min-w-0 gap-x-4 items-center">
          <div :if={submission.order} class="text-gray-400"><%= submission.order + 1 %></div>
          <img class="h-12 w-12 flex-none bg-gray-800" src={submission.track.artwork_url} />
          <div class="min-w-0 flex-auto">
            <p class="text-sm font-semibold leading-6 text-white"><%= submission.track.name %></p>
            <p class="mt-1 truncate text-xs leading-5 text-gray-400">
              <%= submission.track.artist %>
            </p>
          </div>
        </div>
        <div>
          <button phx-click="remove" phx-value-id={submission.id} class="text-gray-400">
            Remove
          </button>
        </div>
      </li>
    </ul>
    """
  end

  def handle_event("remove", %{"id" => id}, socket) do
    submission = Enum.find(socket.assigns.submissions, &(&1.id == id))

    case Vibes.Challenges.remove_submission(submission) do
      {:ok, _submission} ->
        submissions = Enum.reject(socket.assigns.submissions, &(&1.id == id))

        {:noreply,
         socket |> put_flash(:info, "Submission removed") |> assign(submissions: submissions)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to remove submission")}
    end
  end

  def handle_event("reposition", %{"new" => new, "old" => old}, socket) do
    {to_move, submissions} = List.pop_at(socket.assigns.submissions, old)

    submissions =
      submissions
      |> List.insert_at(new, to_move)
      |> Vibes.Challenges.save_order(socket.assigns.current_user)

    {:noreply, assign(socket, submissions: submissions)}
  end
end
