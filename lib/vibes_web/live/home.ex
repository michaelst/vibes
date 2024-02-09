defmodule VibesWeb.Live.Home do
  use VibesWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Welcome to Vibes</h1>
    Welcome <%= @current_user.name %>
    """
  end
end
