defmodule VibesWeb.Live.Home do
  use VibesWeb, :live_view

  require Logger

  def mount(_params, _session, socket) do
    challenge = Vibes.Challenges.current_challenge()

    {:ok, push_navigate(socket, to: ~p"/challenges/#{challenge.id}")}
  rescue
    error ->
      Logger.error("Failed to load home page: #{inspect(error)}")
      {:ok, push_navigate(socket, to: ~p"/")}
  end
end
