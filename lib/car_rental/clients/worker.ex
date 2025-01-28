defmodule CarRental.Clients.Worker do
  alias CarRental.Clients
  alias CarRental.Clients.Params, as: ClientsParams
  alias CarRental.TrustScore
  alias CarRental.TrustScore.Params
  alias CarRental.TrustScore.Params.ClientParams

  use GenServer

  def start_link([clients]) do
    GenServer.start_link(__MODULE__, [clients])
  end

  def init([clients]) do
    init_state =
      clients
      |> Enum.map(fn c ->
        %ClientParams{
          client_id: c.id,
          age: c.age,
          license_number: c.license_number,
          rentals_count: Enum.count(c.rental_history)
        }
      end)

    {:ok, init_state}
  end

  def execute(pid, cmd) do
    GenServer.cast(pid, cmd)
  end

  def handle_cast(:update_score, state) do
    TrustScore.calculate_score(%Params{clients: state})
    |> handle_calcluate_score_result()
    |> create_response(state)
  end

  def handle_info(:update_score, state) do
    TrustScore.calculate_score(%Params{clients: state})
    |> handle_calcluate_score_result()
    |> create_response(state)
  end

  def create_response({_, :stop}, state), do: {:stop, :normal, state}
  def create_response({_, :wait}, state), do: {:noreply, state}

  def handle_calcluate_score_result({:error, "Rate limit exceeded"}) do
    Process.send_after(self(), :update_score, 60000 + :rand.uniform(10000))

    {:ok, :wait}
  end

  def handle_calcluate_score_result(response) do
    response
    |> Enum.each(fn item ->
      params = %ClientsParams{client_id: item.id, score: item.score}
      Clients.save_score_for_client(params)
    end)

    {:ok, :stop}
  end

  def terminate(_, _) do
    IO.inspect("PROCESS TERMINATED")
    :ok
  end
end
