defmodule CarRental.Clients.Supervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def update_weekly_score do
    CarRental.Clients.Registry
    |> Registry.select([{{:"$1", :_, :_}, [], [:"$1"]}])
    |> Enum.each(fn id ->
      CarRental.Clients.Worker.execute(:update_score, id)
    end)
  end

  def spawn_children do
    CarRental.Clients.list_clients()
    |> elem(1)
    |> Enum.chunk_every(100)
    |> Enum.with_index()
    |> Enum.map(fn {clients, index} ->
      DynamicSupervisor.start_child(
        __MODULE__,
        {CarRental.Clients.Worker, [clients, to_string(index)]}
      )
    end)
  end
end
