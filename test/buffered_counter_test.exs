defmodule BufferedCounterTest do
  use ExUnit.Case

  test "add" do
    this = self()
    {:ok, pid} = BufferedCounter.start_link(100, 10, 100, fn n -> send(this, n) end)

    BufferedCounter.add(pid, 9)
    BufferedCounter.add(pid, 2)

    refute_receive(109)
    assert_receive(111)
  end
end
