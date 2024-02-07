defmodule Vibes.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      VibesWeb.Telemetry,
      Vibes.Repo,
      {DNSCluster, query: Application.get_env(:vibes, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Vibes.PubSub},
      # Start a worker by calling: Vibes.Worker.start_link(arg)
      # {Vibes.Worker, arg},
      # Start to serve requests, typically the last entry
      VibesWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Vibes.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VibesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
