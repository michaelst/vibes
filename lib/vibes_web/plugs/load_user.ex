defmodule VibesWeb.Plugs.LoadUser do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    with user_id when is_binary(user_id) <- get_session(conn, :user_id),
         {:ok, user} <- Vibes.Users.get_user(user_id) do
      assign(conn, :current_user, user)
    else
      _not_logged_in -> assign(conn, :current_user, nil)
    end
  end
end
