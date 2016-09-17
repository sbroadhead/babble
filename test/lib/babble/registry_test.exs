defmodule Babble.RegistryTest do
  alias Babble.Registry
  use ExUnit.Case

  test "we can register names" do
    name1 = Registry.name(:foo, "test")
    name2 = Registry.name(:foo, "blah")
    {:ok, pid1} = Agent.start_link fn -> 123 end, name: name1
    {:ok, pid2} = Agent.start_link fn -> 456 end, name: name2
    assert Agent.get(name1, &(&1)) == 123
    assert Registry.whereis_name({:foo, "test"}) == pid1
    :ok = Agent.stop name1
    assert Registry.whereis_name({:foo, "test"}) == :undefined
  end
end
