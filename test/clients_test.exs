defmodule ClientsTest do
  use ExUnit.Case
  alias CarRental.Clients.Params
  doctest CarRental.Clients

  test "list clients works" do
    assert {:ok, clients} = CarRental.Clients.list_clients()
  end

  test "list_clients return 100 clients" do
    {:ok, clients} = CarRental.Clients.list_clients()
    assert Enum.count(clients) == 100
  end

  test "save_score works" do
    assert {:ok, :saved} =
             CarRental.Clients.save_score_for_client(%Params{client_id: 100, score: 10})
  end
end
