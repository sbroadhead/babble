defmodule Babble.RegistryTest do
  alias Babble.Registry
  use ExUnit.Case

  test "we can register names" do
    name = Registry.name(:foo, "test")
    {:ok, pid} = Agent.start_link fn -> 123 end, name: name
    assert Agent.get(name, &(&1)) == 123
    assert Registry.whereis_name({:foo, "test"}) == pid
    :ok = Agent.stop name
    assert Registry.whereis_name({:foo, "test"}) == :undefined
  end
end
