defmodule Babble.TimeTest do
  use ExUnit.Case

  def echo(pid) do
    receive do
      x ->
        send(pid, x)
        echo(pid)
    end
  end

  test "fake time works in unit tests" do
    pid = spawn_link(__MODULE__, :echo, [self])
    :ok = Babble.Time.schedule(pid, :foo, 500)
    :ok = Babble.Time.FakeTime.advance(450)
    receive do
      _ -> flunk "Shouldn't receive anything yet!!"
    after
      0 -> nil
    end
    :ok = Babble.Time.FakeTime.advance(51)
    receive do
      :foo  -> true
      x     -> flunk "What is this? #{inspect x}"
    after
      0 -> flunk "Should've received the value"
    end
  end
end
