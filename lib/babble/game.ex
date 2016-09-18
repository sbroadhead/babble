defmodule Babble.Game do
  alias Babble.Registry

  @moduledoc """
  A `GenServer` process that manages a game lobby.
  """
  use GenServer

  defmodule Options do
    @moduledoc """
    A structure containing the configuration for a lobby.
    """
    defstruct max_players:  12,     # Maximum players in lobby
              password:     "",     # Password to join lobby
              wordlist:     nil,    # Module defining the word list
              combiner:     nil,    # Module defining the word combiner
              name:         "",     # The name of this game
              blacklist:    []      # A list of blacklisted usernames
  end

  defmodule State do
    @moduledoc """
    The state of a lobby instance.
    """
    defstruct options:    nil,      # The `Options` that this lobby was created with
              players:    %{},      # A map of players in this lobby
              blacklist:  [],       # A list of blacklisted usernames
              round:      1         # The round number
  end

  defmodule PlayerState do
    @moduledoc """
    The state of a player in this lobby.
    """
    defstruct sentence:   "",       # The currently submitted sentence for this player
              score:      0,        # The player's current score
              pid:        nil       # The PID of this player's process
  end

  # Public API
  def start_link(%Options{blacklist: blacklist, name: name} = options) do
    state = %State{options: options, blacklist: blacklist}
    GenServer.start_link __MODULE__, state, name: Registry.name(:game, name)
  end

  def join(game, username), do: GenServer.call game, {:join, username}
  def leave(game), do: GenServer.call game, :leave
  def players(game), do: GenServer.call game, :players
  def pid(name), do: Registry.whereis_name {:game, name}

  # GenServer implementation
  def handle_call({:join, username}, {player, _}, %State{blacklist: blacklist, players: players} = state) do
    case Enum.find(blacklist, &(&1 == username)) do
      nil ->
        monitor = Process.monitor(player)
        player_state = %PlayerState{pid: player}
        new_state = %State{state | players: Map.put(players, username, player_state)}
        {:reply, :ok, new_state}
      _ ->
        {:reply, {:error, {:blacklisted, username}}, state}

    end
  end

  def handle_call(:leave, {player, _}, %State{players: players} = state) do
    case Enum.find(players, fn {_, %PlayerState{pid: pid}} -> pid == player end) do
      {_, %PlayerState{pid: pid}} ->
        new_state = %State{state |
          players: players
            |> Enum.filter(fn {_, %PlayerState{pid: x}} -> x != pid end)
            |> Enum.into(Map.new)
        }
        {:reply, :ok, new_state}
      _ ->
        {:reply, {:error, :not_joined}, state}
    end
  end

  def handle_call(:players, _from, %State{players: players} = state),
    do: {:reply, players |> Enum.map(fn {username, _} -> username end), state}


  def handle_info({:DOWN, _, :process, pid, _}, %State{players: players} = state) do
    new_state = %State{state |
      players: players
        |> Enum.filter(fn {_, %PlayerState{pid: x}} -> x != pid end)
        |> Enum.into(Map.new)
    }
    {:noreply, new_state}
  end
end
