defmodule VibesWeb.Components.Live.MySubmission do
  use VibesWeb, :html

  def render(assigns) do
    ~H"""
    <li id={@submission.id} class="flex justify-between items-center py-5 w-full cursor-pointer">
      <div class="flex min-w-0 gap-x-4 items-center">
        <div :if={@submission.order} class="text-gray-400">
          <%= @submission.order + 1 %>
        </div>
        <img class="h-12 w-12 flex-none bg-gray-800" src={@submission.track.artwork_url} />
        <div class="min-w-0 flex-auto">
          <p class="text-sm font-semibold leading-6 text-white">
            <%= @submission.track.name %>
            <span class="mt-1 truncate text-xs leading-5 text-gray-400">
              by <%= @submission.track.artist %>
            </span>
          </p>

          <button
            phx-click="show_modal"
            phx-value-id={@submission.id}
            class="mt-1 truncate text-xs leading-5 text-gray-400 flex items-center"
          >
            <span><%= @submission.youtube_url || "Add details" %></span>
            <.icon name="hero-pencil-square" class="h-4 w-4 ml-1" />
          </button>
        </div>
      </div>
      <div>
        <button
          :if={is_nil(@submission.revealed_at)}
          phx-click="remove"
          phx-value-id={@submission.id}
          class="text-gray-400"
        >
          Remove
        </button>
      </div>
    </li>
    """
  end
end
