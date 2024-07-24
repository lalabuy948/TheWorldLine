defmodule TheWorldLine.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TheWorldLineWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:the_world_line, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TheWorldLine.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: TheWorldLine.Finch},
      # Start a worker by calling: TheWorldLine.Worker.start_link(arg)
      # {TheWorldLine.Worker, arg},
      # Start to serve requests, typically the last entry
      TheWorldLine.MessageStorage,
      TheWorldLine.NicknameStorage,
      TheWorldLine.Presence,
      TheWorldLineWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TheWorldLine.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TheWorldLineWeb.Endpoint.config_change(changed, removed)
    :ok
  end

end
