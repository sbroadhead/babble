# We need a way to test time-based things in unit tests, so we abstract
# the behaviour of future scheduling into a single Time module that we can
# dummy up for unit testing purposes.

defmodule Babble.Time do
  use GenServer

  @callback schedule(dest :: pid, msg :: any, millis :: integer) :: :ok

  def start_link(impl),
    do: GenServer.start __MODULE__, impl, name: __MODULE__

  def schedule(dest, msg, millis),
    do: GenServer.call __MODULE__, {:schedule, dest, msg, millis}

  def handle_call({:schedule, dest, msg, millis}, _from, impl) do
    apply(impl, :schedule, [dest, msg, millis])
    {:reply, :ok, impl}
  end
end

defmodule Babble.Time.RealTime do
  @behaviour Babble.Time
  def schedule(dest, msg, millis) do
    Process.send_after(dest, msg, millis)
  end
end

defmodule Babble.Time.FakeTime do
  @behaviour Babble.Time
  use GenServer

  defmodule State do
    defstruct time: 0,
              callbacks: []
  end

  def start_link,
    do: GenServer.start_link __MODULE__, %State{}, name: __MODULE__

  def advance(millis),
    do: GenServer.call(__MODULE__, {:advance, millis})

  def schedule(dest, msg, millis),
    do: GenServer.call(__MODULE__, {:schedule, dest, msg, millis})

  def handle_call({:schedule, dest, msg, millis}, _from, %State{time: time, callbacks: callbacks} = state) do
    new_state = %State{state | callbacks: [{dest, msg, time + millis} | callbacks]}
    {:reply, :ok, new_state}
  end

  def handle_call({:advance, millis}, _from, %State{time: time, callbacks: callbacks} = state) do
    new_time = time + millis
    callbacks
      |> Enum.filter(fn {_, _, t} -> t <= new_time end)
      |> Enum.map(fn {dest, msg, _} -> send(dest, msg) end)
    new_state = %State{state |
      time: new_time,
      callbacks: callbacks |> Enum.filter(fn {_, _, t} -> t > new_time end)
    }
    {:reply, :ok, new_state}
  end
end
