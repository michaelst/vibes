defmodule VibesWeb.PageController do
  use VibesWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
