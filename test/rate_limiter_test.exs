defmodule RateLimiterTest do
  alias CarRental.TrustScore.RateLimiter
  alias CarRental.TrustScore.Params.ClientParams
  alias CarRental.TrustScore.Params
  use ExUnit.Case
  doctest CarRental.TrustScore

  test "calculate_score works for the first call" do
    responses =
      CarRental.Clients.list_clients()
      |> elem(1)
      |> Enum.map(fn c ->
        %ClientParams{
          client_id: c.id,
          age: c.age,
          license_number: c.license_number,
          rentals_count: Enum.count(c.rental_history)
        }
      end)
      |> Kernel.then(fn c -> %Params{clients: c} end)
      |> CarRental.TrustScore.calculate_score()

    assert Enum.any?(responses) == true
  end

  test "calculate score returns error with 200 clients" do
    clients1 = CarRental.Clients.list_clients() |> elem(1)
    clients2 = CarRental.Clients.list_clients() |> elem(1)

    response =
      (clients1 ++ clients2)
      |> Enum.map(fn c ->
        %ClientParams{
          client_id: c.id,
          age: c.age,
          license_number: c.license_number,
          rentals_count: Enum.count(c.rental_history)
        }
      end)
      |> Kernel.then(fn c -> %Params{clients: c} end)
      |> CarRental.TrustScore.calculate_score()

    assert {:error, "Cannot calculate trust score for more than 100 clients at the same time"} =
             response
  end

  test "return error on rate limit exceeded" do
    result =
      CarRental.Clients.list_clients()
      |> elem(1)
      |> Enum.map(fn c ->
        %ClientParams{
          client_id: c.id,
          age: c.age,
          license_number: c.license_number,
          rentals_count: Enum.count(c.rental_history)
        }
      end)
      |> Kernel.then(fn c ->
        Enum.each(1..10, fn _ ->
          Kernel.spawn(fn ->
            CarRental.TrustScore.calculate_score(%Params{clients: c})
          end)
        end)

        :timer.sleep(4000)

        CarRental.TrustScore.calculate_score(%Params{clients: c})
      end)

    assert {:error, "Rate limit exceeded"} = result
  end
end
