defmodule CarRental.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {CarRental.TrustScore.RateLimiter, []},
      CarRental.Clients.Supervisor,
      CarRental.Scheduler,
      {Registry, [keys: :unique, name: CarRental.Clients.Registry]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CarRental.Supervisor]
    res = Supervisor.start_link(children, opts)

    CarRental.Clients.Supervisor.spawn_children()

    res
  end
end
