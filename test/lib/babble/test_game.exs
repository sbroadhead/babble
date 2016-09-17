defmodule Babble.GameTest do
  use ExUnit.Case
  alias Babble.{Player, Game, Game.Options}

  test "game gets registered in registry" do
    {:ok, pid} = Game.start_link %Options{name: "foo"}
    assert Registry.whereis({:game, "foo"}) == pid
  end

  test "players can join games" do
    {:ok, game} = Game.start_link %Options{name: "foo"}
    {:ok, player1} = Player.start_link "user1"
    {:ok, player2} = Player.start_link "user2"
    {:ok, ^game} = Player.join player1, "foo"
    {:ok, ^game} = Player.join player2, "foo"
    assert pid == game
    assert Game.players(game) == [player1, player2]
    Player.stop player1
    assert Game.players(game) == [player2]
    Player.leave player2
    assert Game.players(game) == []
  end
end
