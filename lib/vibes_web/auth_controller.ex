defmodule VibesWeb.AuthController do
  use VibesWeb, :controller

  alias Vibes.OAuth2.Spotify
  alias Vibes.Users

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: ~p"/login")
  end

  def request(conn, _params) do
    redirect(conn, external: Spotify.authorize_url!())
  end

  def callback(conn, params) do
    {:ok, client} = Spotify.get_user_token(code: params["code"])

    {:ok,
     %{
       body: %{
         "id" => spotify_id,
         "display_name" => name
       }
     }} =
      OAuth2.Client.get(client, "/v1/me")

    {:ok, user} =
      Users.get_or_create_user(%{
        name: name,
        spotify_id: spotify_id,
        spotify_refresh_token: client.token.refresh_token
      })

    conn
    |> put_session(:user_id, user.id)
    |> redirect(to: ~p"/")
  end
end
