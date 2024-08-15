defmodule VibesWeb.Live.HallOfFame do
  use VibesWeb, :live_view

  alias VibesWeb.Components.Live.Submission

  def mount(_params, _session, socket) do
    challenges = Vibes.Challenges.get_final_challenges()
    {:ok, assign(socket, challenges: challenges)}
  rescue
    _error -> {:ok, push_navigate(socket, to: ~p"/")}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 mb-8">
      <div class="mx-auto max-w-7xl flex flex-col gap-10 divide-y divide-gray-800">
        <div :for={challenge <- @challenges} class="pt-10">
          <div class="flex gap-8 flex-col sm:flex-row">
            <div class="w-96 mx-auto">
              <.link href={~p"/challenges/#{challenge.id}"}>
                <img src={challenge.artwork_url} class="h-96 w-96" />
              </.link>
            </div>

            <div class="flex-auto">
              <ul
                :if={challenge.status == :final}
                class="divide-y divide-gray-800 -mt-5 -mb-5"
                id={challenge.id}
              >
                <Submission.render
                  :for={submission <- Vibes.Challenges.get_all_submissions(challenge)}
                  :if={submission.rank <= 5}
                  submission={submission}
                  challenge={challenge}
                  simple={true}
                />
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
