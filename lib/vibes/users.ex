defmodule Vibes.Users do
  alias Vibes.Repo
  alias Vibes.Users.User

  def get_user(id) do
    case Repo.get(User, id) do
      user when is_struct(user) -> {:ok, user}
      _nil -> {:error, :not_found}
    end
  end

  def get_or_create_user(params) do
    case Repo.get_by(User, spotify_id: params.spotify_id) do
      nil ->
        params
        |> User.changeset()
        |> Repo.insert()

      user ->
        {:ok, user}
    end
  end
end
