defmodule Babble.Game do
  alias Babble.{Registry, Player}

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
              players:    [],       # A list of pids representing the players in this lobby
              blacklist:  []        # A list of blacklisted usernames
  end

  # Public API
  def start_link(%Options{blacklist: blacklist, name: name} = options) do
    state = %State{options: options, blacklist: blacklist}
    GenServer.start_link __MODULE__, state, Registry.name(:game, name)
  end

  def join(name), do: GenServer.call Registry.name(:game, name), :join
  def leave(name), do: GenServer.call Registry.name(:game, name), :leave
  def players(name), do: GenServer.call Registry.name(:game, name), :players
  def pid(name), do: Registry.whereis_name {:game, name}

  # GenServer implementation
  def handle_call(:join, player, %State{blacklist: blacklist, players: players} = state) do
    name = Player.name player
    case Enum.find(blacklist, &(&1 == name)) do
      nil ->
        monitor = Process.monitor(player)
        new_state = %State{state | players: [{player, monitor} | players]}
        {:reply, {:ok, self}, new_state}
      _ ->
        {:reply, {:blacklisted, name}, state}

    end
  end

  def handle_call(:leave, player, %State{players: players} = state) do
    case Enum.find(players, fn {pid, _} -> pid == player end) do
      {pid, _} ->
        new_state = %State{state | players: players |> Enum.filter(fn {x, _} -> x != pid end)}
        {:reply, :ok, new_state}
      _ ->
        {:reply, {:error, :not_joined}, state}
    end
  end

  def handle_info({:down, _, :process, pid, _}, %State{players: players} = state) do
    new_state = %State{state | players: players |> Enum.filter(&(&1 != pid))}
    {:noreply, new_state}
  end
end
