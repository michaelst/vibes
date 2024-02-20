defmodule VibesWeb.Live.Challenges do
  use VibesWeb, :live_view

  def mount(_params, _session, socket) do
    challenges = Vibes.Challenges.get_challenges()
    {:ok, assign(socket, challenges: challenges)}
  rescue
    _error -> {:ok, push_navigate(socket, to: ~p"/")}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 mb-8">
      <div class="mx-auto max-w-7xl px-6 lg:px-8 grid grid-cols-3 gap-4">
        <.link :for={challenge <- @challenges} href={~p"/challenges/#{challenge.id}"}>
          <img src={challenge.artwork_url} />
        </.link>
      </div>
    </div>
    """
  end
end
