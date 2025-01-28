defmodule CarRental.Clients.Supervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def update_weekly_score do
    CarRental.Clients.list_clients()
    |> elem(1)
    |> Enum.chunk_every(100)
    |> Enum.map(fn clients ->
      {:ok, pid} =
        DynamicSupervisor.start_child(
          __MODULE__,
          {CarRental.Clients.Worker, [clients]}
        )

      pid
    end)
    |> Enum.map(fn pid -> CarRental.Clients.Worker.execute(pid, :update_score) end)
  end
end
