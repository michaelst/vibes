defmodule VibesWeb.Router do
  use VibesWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {VibesWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", VibesWeb do
    pipe_through :browser

    get "/login", PageController, :login
    get "/logout", AuthController, :logout

    get "/auth/request", AuthController, :request
    get "/auth/callback", AuthController, :callback
  end

  live_session :authenticated, on_mount: VibesWeb.Live.OnMount do
    scope "/", VibesWeb.Live do
      pipe_through :browser

      live "/", Home
      live "/challenges/:id", Challenge
      live "/challenges/:id/submit", Submit
    end
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:vibes, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: VibesWeb.Telemetry
    end
  end
end
