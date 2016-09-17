defmodule Babble.Registry do
  #
  # This is the Babble GenServer process registry. The default registry used
  # by Process.register doesn't allow us to register a name like {:user, "username"},
  # so we use this one instead.
  #
  # When processes are registered, they are automatically monitored so that they
  # get removed when the process ends.
  #

  use GenServer

  # Public API
  def start_link,
    do: GenServer.start_link __MODULE__, %{}, name: __MODULE__

  def whereis_name({type, _name} = key) when is_atom(type),
    do: GenServer.call(__MODULE__, {:whereis_name, key})

  def register_name({type, _name} = key, pid) when is_atom(type) and is_pid(pid),
    do: GenServer.call(__MODULE__, {:register_name, key, pid})

  def unregister_name({type, _name} = key) when is_atom(type),
    do: GenServer.cast(__MODULE__, {:unregister_name, key})

  def send({type, _name} = key, message) when is_atom(type) do
    case whereis_name(key) do
      :undefined ->
        {:badarg, {key, message}}
      pid when is_pid(pid) ->
        Kernel.send(pid, message)
        pid
    end
  end

  def name(type, name) when is_atom(type),
    do: {:via, __MODULE__, {type, name}}

  # GenServer implementation
  def handle_call({:whereis_name, {type, _name} = key}, _from, registry) when is_atom(type),
    do: {:reply, Map.get(registry, key, :undefined), registry}

  def handle_call({:register_name, {type, _name} = key, pid}, _from, registry)
    when is_atom(type) and is_pid(pid) do
    Process.monitor pid
    case Map.get(registry, key) do
      nil -> {:reply, :yes, Map.put(registry, key, pid)}
      _   -> {:reply, :no, registry}
    end
  end

  def handle_cast({:unregister_name, {type, _name} = key}, _from, registry) when is_atom(type),
    do: {:noreply, Map.delete(registry, key)}

  def handle_info({:DOWN, _, :process, pid, _}, registry) do
    {key, ^pid} = Map.to_list(registry) |> Enum.find(fn {_, ^pid} -> true end)
    {:noreply, Map.delete(registry, key)}
  end

end
