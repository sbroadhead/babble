defmodule Babble.GameTest do
  use ExUnit.Case
  alias Babble.{Registry, Player, Game, Game.Options}

  test "game gets registered in registry" do
    {:ok, pid} = Game.start_link %Options{name: "foo"}
    assert Registry.whereis_name({:game, "foo"}) == pid
  end

  test "players can join games" do
    {:ok, game} = Game.start_link %Options{name: "foo"}
    {:ok, player1} = Player.start_link "user1"
    {:ok, player2} = Player.start_link "user2"
    :ok = Player.join player1, game
    :ok = Player.join player2, game
    assert Player.game(player1) == game
    assert Player.game(player2) == game
    assert Enum.sort(Game.players(game)) == ["user1", "user2"]
    Player.stop player1
    assert Game.players(game) == ["user2"]
    Player.leave player2
    assert Game.players(game) == []
    assert Player.game(player2) == nil
  end

  test "players can be blacklisted from games" do
    {:ok, game} = Game.start_link %Options{name: "foo", blacklist: ["baduser"]}
    {:ok, player1} = Player.start_link "baduser"
    {:ok, player2} = Player.start_link "gooduser"
    {:error, {:blacklisted, "baduser"}} = Player.join player1, game
    :ok = Player.join player2, game
  end
end
