defmodule VibesWeb.Live.Home do
  use VibesWeb, :live_view

  def mount(_params, _session, socket) do
    challenge = Vibes.Challenges.current_challenge()
    submissions = Vibes.Challenges.get_submissions(challenge.id, socket.assigns.current_user.id)

    {:ok,
     assign(socket,
       challenge: challenge,
       submissions: submissions,
       editing: nil,
       form: nil
     )}
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
          <div :if={length(@submissions) < @challenge.tracks_per_user} class="mt-8">
            <.link
              navigate={~p"/submit"}
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
        class="flex justify-between items-center gap-x-6 py-5"
      >
        <div class="flex min-w-0 gap-x-4">
          <div :if={submission.order} class="text-gray-400"><%= submission.order + 1 %></div>
          <img class="h-12 w-12 flex-none bg-gray-800" src={submission.track.artwork_url} />
          <div class="min-w-0 flex-auto">
            <p class="text-sm font-semibold leading-6 text-white">
              <%= submission.track.name %>
              <span class="mt-1 truncate text-xs leading-5 text-gray-400">
                by <%= submission.track.artist %>
              </span>
            </p>

            <button
              phx-click="show_modal"
              phx-value-id={submission.id}
              class="mt-1 truncate text-xs leading-5 text-gray-400 flex items-center"
            >
              <span><%= submission.youtube_url || "Add YouTube Link" %></span>
              <.icon name="hero-pencil-square" class="h-4 w-4 ml-1" />
            </button>
          </div>
        </div>
        <div>
          <button phx-click="remove" phx-value-id={submission.id} class="text-gray-400">
            Remove
          </button>
        </div>
      </li>
    </ul>
    <!-- modal -->
    <div class="relative z-10" aria-labelledby="modal-title" role="dialog" aria-modal="true">
      <div
        :if={not is_nil(@editing)}
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
      >
      </div>

      <div :if={not is_nil(@editing)} class="fixed inset-0 z-10 w-screen overflow-y-auto">
        <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
          <div class="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:p-6">
            <div class="sm:flex sm:items-start">
              <div class="mx-auto flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full bg-gray-100 sm:mx-0 sm:h-10 sm:w-10">
                <.icon name="hero-link" class="h-6 w-6" />
              </div>
              <.form for={@form} class="w-full" phx-submit="update_youtube_url">
                <div class="mt-3 text-center sm:ml-4 sm:mt-0 sm:text-left">
                  <h3 class="text-base font-semibold leading-6 text-gray-900">
                    Update YouTube Link
                  </h3>
                  <div class="mt-2">
                    <.input field={@form[:youtube_url]} />
                  </div>
                </div>
                <div class="mt-5 sm:mt-4 sm:flex sm:pl-4">
                  <button
                    type="submit"
                    class="inline-flex w-full justify-center rounded-md bg-blue-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 sm:w-auto"
                  >
                    Update
                  </button>
                  <button
                    type="button"
                    phx-click="close_modal"
                    class="mt-3 inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:ml-3 sm:mt-0 sm:w-auto"
                  >
                    Cancel
                  </button>
                </div>
              </.form>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("show_modal", %{"id" => id}, socket) do
    submission = Enum.find(socket.assigns.submissions, &(&1.id == id))
    form = to_form(%{"youtube_url" => submission.youtube_url})
    {:noreply, assign(socket, editing: submission, form: form)}
  end

  def handle_event("update_youtube_url", params, socket) do
    case Vibes.Challenges.update_submission(socket.assigns.editing, params) do
      {:ok, submission} ->
        submissions =
          Enum.map(socket.assigns.submissions, fn s ->
            if s.id == submission.id, do: submission, else: s
          end)

        {:noreply,
         socket
         |> put_flash(:info, "YouTube link updated")
         |> assign(submissions: submissions, editing: nil, form: nil)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to update YouTube link")}
    end
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, editing: nil, form: nil)}
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
