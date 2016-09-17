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
  def join(player, game_name), do: GenServer.call player, {:join, game_name}
  def leave(player), do: GenServer.call player, :leave
  def pid(username), do: Registry.whereis_name {:user, username}

  # GenServer implementation
  def handle_call(:name, _from, %State{name: name} = state),
    do: {:reply, name, state}

  def handle_call(:leave, _from, %State{game: game} = state) do
    case game and Game.leave game do
      :ok ->
        new_state = %State{state | game: nil}
        {:reply, :ok, new_state}
      _ ->
        {:reply, {:error, :not_joined}, state}
    end
  end

  def handle_call({:join, game_name}, _from, %State{} = state) do
    case Game.join game_name do
      {:ok, pid} ->
        new_state = %State{state | game: pid}
        {:reply, :ok, new_state}
    end
  end
end
