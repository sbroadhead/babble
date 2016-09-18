defmodule Babble.Player do
  use GenServer
  alias Babble.{Registry, Game}

  defmodule State do
    defstruct name: "",
              game: nil
  end

  # Public API
  def start_link(username) do
    state = %State{name: username}
    GenServer.start_link __MODULE__, state, name: Registry.name(:user, username)
  end

  def stop(player), do: GenServer.stop player
  def name(player), do: GenServer.call player, :name
  def game(player), do: GenServer.call player, :game
  def join(player, game) when is_pid(game), do: GenServer.call player, {:join, game}
  def leave(player), do: GenServer.call player, :leave
  def pid(username), do: Registry.whereis_name {:user, username}

  # GenServer implementation
  def handle_call(:name, _from, %State{name: name} = state),
    do: {:reply, name, state}

  def handle_call(:game, _from, %State{game: game} = state),
    do: {:reply, game, state}

  def handle_call(:leave, _from, %State{game: nil} = state),
    do: {:reply, {:error, :not_joined}, state}

  def handle_call(:leave, _from, %State{game: game} = state) do
    case Game.leave game do
      :ok ->
        new_state = %State{state | game: nil}
        {:reply, Game.leave(game), new_state}
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:join, game}, _from, %State{name: name} = state) do
    case Game.join game, name do
      :ok ->
        new_state = %State{state | game: game}
        {:reply, :ok, new_state}
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end
end
