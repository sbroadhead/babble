defmodule Babble.WordList do
  use GenServer

  @callback create_wordlist() :: [String.t]

  # API
  def start_link(impl),
    do: GenServer.start_link(__MODULE__, impl)

  def create_wordlist(wordlist),
    do: GenServer.call(wordlist, :create_wordlist)

  # GenServer implementation
  def handle_call(:create_wordlist, _from, impl),
    do: {:reply, apply(impl, :create_wordlist, []), impl}
end

defmodule Babble.WordList.Dummy do
  @behaviour Babble.WordList

  def create_wordlist,
    do: ["foo", "bar", "baz", "-s", "-ing"]
end
