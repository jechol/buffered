defmodule BufferedCounterTest do
  use ExUnit.Case

  setup do
    this = self()
    {:ok, pid} = BufferedCounter.start_link(100, 10, 100, fn n -> send(this, n) end)

    {:ok, %{pid: pid}}
  end

  test "idle -> idle", %{pid: pid} do
    BufferedCounter.add(pid, 11)
    assert_receive(111)
  end

  test "idle -> buffering -> idle", %{pid: pid} do
    BufferedCounter.add(pid, 9)
    BufferedCounter.add(pid, 2)

    refute_receive(109)
    assert_receive(111)
  end

  test "idle -> buffering -> timeout", %{pid: pid} do
    BufferedCounter.add(pid, 9)
    refute_receive(109)

    Process.sleep(100)
    assert_receive(109)
  end

  test "flush on idle", %{pid: pid} do
    BufferedCounter.flush(pid)
    assert_receive(100)
  end

  test "flush on buffering", %{pid: pid} do
    BufferedCounter.add(pid, 9)
    refute_receive(109)

    BufferedCounter.flush(pid)
    assert_receive(109)
  end
end
