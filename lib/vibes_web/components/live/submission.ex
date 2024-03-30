defmodule VibesWeb.Components.Live.Submission do
  use VibesWeb, :html

  def render(assigns) do
    ~H"""
    <li
      id={@submission.id}
      class={[
        "flex py-5 w-full flex-col text-white",
        not is_nil(@submission.ratings_revealed_at) && @submission.rank > 5 && "opacity-25"
      ]}
    >
      <div class="flex w-full items-center justify-between">
        <div class="flex gap-x-4 items-center flex-1">
          <div :if={@submission.ratings_revealed_at} class="text-gray-400">
            <%= @submission.rank %>
          </div>
          <img class="h-12 w-12 flex-none bg-gray-800" src={@submission.track.artwork_url} />
          <div>
            <p class="text-sm font-semibold leading-6 text-white flex">
              <span class="truncate text-white"><%= @submission.track.name %></span>
              <.link href={@submission.youtube_url} target="_blank">
                <img src={~p"/images/youtube.svg"} class="h-6 w-6 inline ml-1" />
              </.link>
            </p>
            <p class="mt-1 truncate text-xs leading-5 text-gray-400">
              by <%= @submission.track.artist %>
            </p>
          </div>
        </div>

        <div :if={@submission.ratings_revealed_at} class="flex items-center">
          <div class="w-full flex tems-center gap-x-4">
            <div
              :for={rating <- Enum.sort_by(@submission.ratings, & &1.user.name)}
              class="flex flex-1 max-w-xs flex-col gap-y-1 text-center"
            >
              <dd class="font-semibold tracking-tight text-white text-lg">
                <%= rating.rating %>
              </dd>
              <dt class="text-xs text-gray-400 whitespace-nowrap"><%= rating.user.name %></dt>
            </div>
          </div>
          <span class="text-3xl ml-8"><%= @submission.rating %></span>
        </div>

        <div
          :if={not is_nil(@submission.ratings_revealed_at)}
          class="text-right min-w-40 flex flex-col gap-y-1"
        >
          <span class="text-xs text-gray-400 ">submitted by</span>
          <span class="text-sm"><%= @submission.user.name %></span>
        </div>
      </div>
    </li>
    """
  end
end
