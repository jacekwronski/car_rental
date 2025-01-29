defmodule CarRental.Clients.Supervisor do
  require Logger
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def update_weekly_score do
    Logger.info("Start update weekly score")

    CarRental.Clients.list_clients()
    |> elem(1)
    |> Enum.chunk_every(100)
    |> Enum.with_index()
    |> Enum.map(fn {clients, index} ->
      {:ok, pid} =
        DynamicSupervisor.start_child(__MODULE__, %{
          id: index,
          start: {CarRental.Clients.Worker, :start_link, [clients]},
          restart: :transient
        })

      pid
    end)
    |> Enum.map(&CarRental.Clients.Worker.execute(&1, :update_score))
  end
end
