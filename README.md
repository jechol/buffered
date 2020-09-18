# Buffered

Buffered Queue and Counter for Erlang/Elixir

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `buffered` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:buffered, "~> 0.1.0"}
  ]
end
```

## BufferedCounter

```elixir
{:ok, pid} = BufferedCounter.start_link(%{start: 100, threshold: 10, timeout: 5000}, &IO.inspect/1)

BufferedCounter.add(pid, 9)
BufferedCounter.add(pid, 2)
# 111 immediately due to threshold

BufferedCounter.add(pid, 2)
# 113 after 5s due to timeout
```

## BufferedQueue

```elixir
{:ok, pid} = BufferedQueue.start_link(%{size: 2, timeout: 5000}, &IO.inspect/1)

BufferedQueue.enqueue(pid, [1])
BufferedQueue.enqueue(pid, [2, 3])
# [1, 2, 3] immediately due to size

BufferedQueue.enqueue(pid, [4])
# [4] after 5s due to timeout
```
