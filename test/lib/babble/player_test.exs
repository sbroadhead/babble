defmodule Babble.PlayerTest do
  use ExUnit.Case
  alias Babble.{Registry, Player}

  test "player gets registered in registry" do
    {:ok, pid} = Player.start_link "foobar"
    assert Registry.whereis_name({:user, "foobar"}) == pid
  end

  test "name" do
    {:ok, pid} = Player.start_link "foobar"
    assert Player.name(pid) == "foobar"
  end
end
