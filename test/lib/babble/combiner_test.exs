defmodule Babble.CombinerTest do
  use ExUnit.Case
  alias Babble.Combiner

  test "combiner works" do
    {:ok, pid} = Combiner.start_link(Combiner.Trivial)
    assert Combiner.combine(pid, ["hello", "world", "how", "are", "you"]) == "hello world how are you"
  end
end
