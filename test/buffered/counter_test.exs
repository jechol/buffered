defmodule Buffered.CounterTest do
  use ExUnit.Case, async: true
  alias Buffered.Counter

  @timeout 300

  setup do
    this = self()

    {:ok, pid} =
      Counter.start_link(%{start: 100, threshold: 10, timeout: @timeout}, fn n ->
        send(this, n)
      end)

    assert_received(100)

    {:ok, %{pid: pid}}
  end

  test "idle -> idle", %{pid: pid} do
    :ok = Counter.add(pid, 11)
    assert_receive(111)
  end

  test "idle -> idle for negative", %{pid: pid} do
    :ok = Counter.add(pid, -11)
    assert_receive(89)
  end

  test "idle -> buffering -> idle", %{pid: pid} do
    :ok = Counter.add(pid, 9)
    :ok = Counter.add(pid, 2)

    refute_receive(109)
    assert_receive(111)
  end

  test "idle -> buffering -> timeout", %{pid: pid} do
    :ok = Counter.add(pid, 9)
    refute_receive(109)

    Process.sleep(@timeout)
    assert_receive(109)
  end

  test "flush on idle", %{pid: pid} do
    :ok = Counter.flush(pid)
    assert_receive(100)
  end

  test "flush on buffering", %{pid: pid} do
    :ok = Counter.add(pid, 9)
    refute_receive(109)

    :ok = Counter.flush(pid)
    assert_receive(109)
  end
end
