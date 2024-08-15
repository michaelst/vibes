defmodule VibesWeb.Live.Challenges do
  use VibesWeb, :live_view

  def mount(_params, _session, socket) do
    challenges = Vibes.Challenges.get_active_challenges()
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

            <div class="flex-auto text-gray-50">
              <div :if={challenge.status == :rate} class="flex flex-col">
                <div class="text-sm text-gray-400">Ratings due:</div>
                <format-date date={challenge.rating_due_date}></format-date>
              </div>
              <div :if={challenge.status == :active} class="flex flex-col">
                <div class="text-sm text-gray-400">Submissions due:</div>
                <format-date date={challenge.submission_due_date}></format-date>
                <div class="mt-4 text-sm text-gray-400">Ratings due:</div>
                <format-date date={challenge.rating_due_date}></format-date>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
