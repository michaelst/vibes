defmodule VibesWeb.PageController do
  use VibesWeb, :controller

  def login(conn, _params) do
    render(conn, :login, layout: false)
  end
end
