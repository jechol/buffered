# Buffered

Buffered queue and counter for Erlang/Elixir

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

## Usage

### BufferedCounter

```elixir
alias Buffered.Counter
{:ok, pid} = Counter.start_link(%{start: 100, threshold: 10, timeout: 5000}, &IO.inspect/1)

Counter.add(pid, 9)
Counter.add(pid, 2)
# 111 immediately due to threshold

Counter.add(pid, 2)
Process.sleep(5000)
# 113 after 5s due to timeout

Counter.add(pid, -8)
Counter.flush(pid)
# 105 due to flush
```

### Queue

```elixir
alias Buffered.Queue
{:ok, pid} = Queue.start_link(%{size: 2, timeout: 5000}, &IO.inspect/1)

Queue.enqueue(pid, [1])
Queue.enqueue(pid, [2, 3])
# [1, 2, 3] immediately due to size

Queue.enqueue(pid, [4])
Process.sleep(5000)
# [4] after 5s due to timeout

Queue.enqueue(pid, [5])
Queue.flush(pid)
# [5] due to flush
```
