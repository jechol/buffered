defmodule Buffered.CounterTest do
  use ExUnit.Case, async: true
  alias Buffered.Counter

  setup do
    this = self()

    {:ok, pid} =
      Counter.start_link(%{start: 100, threshold: 10, timeout: 100}, fn n ->
        send(this, n)
      end)

    {:ok, %{pid: pid}}
  end

  test "idle -> idle", %{pid: pid} do
    Counter.add(pid, 11)
    assert_receive(111)
  end

  test "idle -> idle for negative", %{pid: pid} do
    Counter.add(pid, -11)
    assert_receive(89)
  end

  test "idle -> buffering -> idle", %{pid: pid} do
    Counter.add(pid, 9)
    Counter.add(pid, 2)

    refute_receive(109)
    assert_receive(111)
  end

  test "idle -> buffering -> timeout", %{pid: pid} do
    Counter.add(pid, 9)
    refute_receive(109)

    Process.sleep(100)
    assert_receive(109)
  end

  test "flush on idle", %{pid: pid} do
    Counter.flush(pid)
    assert_receive(100)
  end

  test "flush on buffering", %{pid: pid} do
    Counter.add(pid, 9)
    refute_receive(109)

    Counter.flush(pid)
    assert_receive(109)
  end
end
