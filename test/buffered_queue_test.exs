defmodule BufferedQueueTest do
  use ExUnit.Case

  test "enqueue" do
    this = self()
    {:ok, pid} = BufferedQueue.start_link(2, 100, fn n -> send(this, n) end)

    BufferedQueue.enqueue(pid, [1])
    BufferedQueue.enqueue(pid, [2, 3])

    refute_receive([1])
    assert_receive([1, 2, 3])
  end
end
