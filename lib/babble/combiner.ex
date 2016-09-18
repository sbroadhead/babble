defmodule Babble.Combiner do
  use GenServer

  @callback combine(tokens :: [String.t]) :: String.t

  # API
  def start_link(impl) when is_atom(impl),
    do: GenServer.start_link(__MODULE__, impl)

  def combine(combiner, tokens) when is_list(tokens),
    do: GenServer.call(combiner, {:combine, tokens})

  # GenServer implementation
  def handle_call({:combine, tokens}, _from, impl),
    do: {:reply, apply(impl, :combine, [tokens]), impl}
end

defmodule Babble.Combiner.Trivial do
  @behaviour Babble.Combiner

  def combine(tokens) when is_list(tokens),
    do: Enum.join(tokens, " ")
end
