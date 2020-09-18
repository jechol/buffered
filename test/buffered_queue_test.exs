defmodule BufferedQueueTest do
  use ExUnit.Case

  setup do
    this = self()

    {:ok, pid} =
      BufferedQueue.start_link(%{size: 2, timeout: 100}, fn items -> send(this, items) end)

    {:ok, %{pid: pid}}
  end

  test "idle -> idle", %{pid: pid} do
    BufferedQueue.enqueue(pid, [1, 2, 3])
    assert_receive([1, 2, 3])
  end

  test "idle -> buffering -> idle", %{pid: pid} do
    BufferedQueue.enqueue(pid, [1])
    BufferedQueue.enqueue(pid, [2, 3])

    refute_receive([1])
    assert_receive([1, 2, 3])
  end

  test "idle -> buffering -> idle -> idle", %{pid: pid} do
    BufferedQueue.enqueue(pid, [1])
    BufferedQueue.enqueue(pid, [2, 3])
    BufferedQueue.enqueue(pid, [4, 5])

    refute_receive([1])
    assert_receive([1, 2, 3])
    assert_receive([4, 5])
  end

  test "idle -> buffering -> timeout -> idle", %{pid: pid} do
    BufferedQueue.enqueue(pid, [1])
    refute_receive([1])

    Process.sleep(100)
    assert_receive([1])

    BufferedQueue.enqueue(pid, [4, 5])
    assert_receive([4, 5])
  end

  test "flush on idle", %{pid: pid} do
    BufferedQueue.flush(pid)
    assert_receive([])
  end

  test "flush on buffering", %{pid: pid} do
    BufferedQueue.enqueue(pid, [1])
    refute_receive([1])

    BufferedQueue.flush(pid)
    assert_receive([1])
  end
end
