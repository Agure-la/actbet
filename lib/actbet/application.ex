defmodule Actbet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ActbetWeb.Telemetry,
      Actbet.Repo,
      {DNSCluster, query: Application.get_env(:actbet, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Actbet.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Actbet.Finch},
      # Start a worker by calling: Actbet.Worker.start_link(arg)
      # {Actbet.Worker, arg},
      # Start to serve requests, typically the last entry
      ActbetWeb.Endpoint,
      Actbet.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Actbet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ActbetWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
