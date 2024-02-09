defmodule VibesWeb.Live.OnMount do
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:default, _params, session, socket) do
    socket =
      assign_new(socket, :current_user, fn ->
        if session["user_id"] do
          {:ok, user} = Vibes.Users.get_user(session["user_id"])
          user
        end
      end)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/login")}
    end
  end
end
