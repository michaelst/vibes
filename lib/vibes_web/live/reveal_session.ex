defmodule VibesWeb.Live.RevealSession do
  use VibesWeb, :live_view

  alias VibesWeb.Components.Live.Submission

  def mount(_params, _session, socket) do
    challenge = Vibes.Challenges.current_challenge("reveal")
    submissions = Vibes.Challenges.get_all_submissions(challenge.id)
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
        <Submission.render
          :for={submission <- @submissions}
          :if={not is_nil(submission.revealed_at)}
          submission={submission}
          challenge={@challenge}
        />
      </ul>
    </div>
    """
  end

  def handle_event("reveal", _params, socket) do
    submission = Vibes.Challenges.reveal_submission(socket.assigns.challenge.id)
    {:noreply, push_navigate(socket, to: ~p"/reveal/#{submission.id}")}
  end
end
