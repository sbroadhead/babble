defmodule Babble.Player do
  use GenServer
  alias Babble.Registry

  defmodule State do
    defstruct name: ""
  end

  # Public API
  def start_link(username) do
    state = %State{name: username}
    GenServer.start_link __MODULE__, state, name: Registry.name(:user, username)
  end

  def name(player), do: GenServer.call(player, :name)

  # GenServer implementation
  def handle_call(:name, _from, %State{name: name} = state),
    do: {:reply, name, state}
end
