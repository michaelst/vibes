defmodule VibesWeb.Live.Challenge do
  use VibesWeb, :live_view

  alias VibesWeb.Components.Live.FormModal
  alias VibesWeb.Components.Live.MySubmission
  alias VibesWeb.Components.Live.Submission

  require Logger

  def mount(%{"id" => id}, _session, socket) do
    challenge = Vibes.Challenges.get_challenge(id)

    submissions = fetch_submissions(challenge, socket.assigns.current_user)

    {:ok,
     assign(socket,
       challenge: challenge,
       submissions: submissions,
       editing: nil,
       form: nil
     )}
  rescue
    error ->
      Logger.error("Failed to load home page: #{inspect(error)}")
      {:ok, push_navigate(socket, to: ~p"/")}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 mb-8">
      <div class="mx-auto max-w-7xl px-6">
        <div class="mx-auto max-w-2xl text-center">
          <h2
            :if={@challenge.status == :upcoming}
            class="text-base font-semibold leading-7 text-indigo-400"
          >
            Coming Soon
          </h2>
          <h2
            :if={@challenge.status in [:active, :reveal, :vibe_check]}
            class="text-base font-semibold leading-7 text-indigo-400"
          >
            Current Challenge
          </h2>
          <img src={@challenge.artwork_url} class="my-6 mx-auto h-[300px]" />
          <p :if={@challenge.status == :vibe_check} class="text-sm text-gray-300">
            Drag and drop songs in your rating order.
          </p>
          <div
            :if={
              length(@submissions) < @challenge.tracks_per_user and
                @challenge.status in [:active, :reveal]
            }
            class="mt-8"
          >
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
    <ul
      :if={@challenge.status in [:active, :reveal]}
      phx-hook="Sortable"
      class="divide-y divide-gray-800 max-w-2xl mx-auto"
      id={@challenge.id}
    >
      <MySubmission.render
        :for={submission <- @submissions}
        :if={submission.user_id == @current_user.id}
        submission={submission}
        challenge={@challenge}
      />
    </ul>
    <ul
      :if={@challenge.status == :rate}
      phx-hook="Sortable"
      class="divide-y divide-gray-800 max-w-2xl mx-auto"
      id={@challenge.id}
    >
      <Submission.render
        :for={submission <- @submissions}
        submission={submission}
        challenge={@challenge}
      />
    </ul>
    <ul :if={@challenge.status == :final} class="divide-y divide-gray-800 w-full" id={@challenge.id}>
      <Submission.render
        :for={submission <- @submissions}
        submission={submission}
        challenge={@challenge}
      />
    </ul>
    <FormModal.render form={@form} editing={@editing} />
    """
  end

  def handle_event("show_modal", %{"id" => id}, socket) do
    submission = Enum.find(socket.assigns.submissions, &(&1.id == id))
    form = to_form(Vibes.Challenges.Submission.update_changeset(submission, %{}))
    {:noreply, assign(socket, editing: submission, form: form)}
  end

  def handle_event("validate_submission_details", %{"submission" => params}, socket) do
    form =
      socket.assigns.editing
      |> Vibes.Challenges.Submission.update_changeset(params)
      |> Map.put(:action, :update)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("update_submission_details", %{"submission" => params}, socket) do
    case Vibes.Challenges.update_submission(socket.assigns.editing, params) |> dbg do
      {:ok, submission} ->
        submissions =
          Enum.map(socket.assigns.submissions, fn s ->
            if s.id == submission.id, do: submission, else: s
          end)

        {:noreply,
         socket
         |> put_flash(:info, "Submission details updated")
         |> assign(submissions: submissions, editing: nil, form: nil)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to update submission")}
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
    %{assigns: %{submissions: submissions, challenge: challenge, current_user: user}} = socket

    {to_move, submissions} = List.pop_at(submissions, old)
    new_order = List.insert_at(submissions, new, to_move)

    case challenge.status do
      status when status in [:active, :reveal] ->
        Vibes.Challenges.save_order(new_order, user)

      :rate ->
        Vibes.Challenges.save_ratings(new_order, user)
    end

    submissions = fetch_submissions(challenge, user)

    {:noreply, assign(socket, submissions: submissions)}
  end

  defp fetch_submissions(challenge, user) do
    if challenge.status in [:active, :reveal] do
      Vibes.Challenges.get_submissions(challenge.id, user.id)
    else
      Vibes.Challenges.get_all_submissions(challenge)
    end
    # filter so only the current user's ratings are shown
    |> Enum.map(fn submission ->
      rating =
        case Enum.find(submission.ratings, &(&1.user_id == user.id)) do
          %{rating: rating} -> rating
          _none -> nil
        end

      Map.put_new(submission, :rating, rating)
    end)
    |> Enum.sort_by(fn submission ->
      case challenge.status do
        :vibe_check -> submission.rating
        _status -> submission.order
      end
    end)
  end
end
