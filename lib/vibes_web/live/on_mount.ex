defmodule VibesWeb.Live.OnMount do
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:default, _params, session, socket) do
    socket =
      socket
      |> assign_new(:current_user, fn ->
        if session["user_id"] do
          {:ok, user} = Vibes.Users.get_user(session["user_id"])
          user
        end
      end)
      |> assign_new(:spotify_token, fn %{current_user: user} ->
        {:ok, %{token: %{access_token: token}}} =
          Vibes.OAuth2.Spotify.refresh_user_token(user.spotify_refresh_token)

        token
      end)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/login")}
    end
  end
end
