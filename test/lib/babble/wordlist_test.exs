defmodule Babble.WordListTest do
  use ExUnit.Case
  alias Babble.WordList

  test "wordlist works" do
    {:ok, pid} = WordList.start_link(WordList.Dummy)
    assert WordList.create_wordlist(pid) == ["foo", "bar", "baz", "-s", "-ing"]
  end
end
