![mix test](https://github.com/jechol/buffered/workflows/mix%20test/badge.svg)
![Hex.pm](https://img.shields.io/hexpm/v/buffered)

# Buffered

Buffered queue and counter for Erlang/Elixir

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `buffered` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:buffered, "~> 0.2.1"}
  ]
end
```

## Usage

### Queue

```elixir
alias Buffered.Queue
{:ok, pid} = Queue.start_link(%{size: 2, timeout: 3000}, &IO.inspect/1)

Queue.enqueue(pid, [1])
Queue.enqueue(pid, [2, 3])
# [1, 2, 3] immediately as size of [1, 2, 3] > size 2

Queue.enqueue(pid, [4])
Process.sleep(5000)
# [4] as ellapsed time 5000ms > timeout 3000ms

Queue.enqueue(pid, [5])
Queue.flush(pid)
# [5] due to flush
```

### Counter

```elixir
alias Buffered.Counter
{:ok, pid} = Counter.start_link(%{start: 100, threshold: 10, timeout: 3000}, &IO.inspect/1)

Counter.add(pid, 9)
Counter.add(pid, 2)
# 111 immediately as change 11 > threshold 10

Counter.add(pid, 2)
Process.sleep(5000)
# 113 as ellapsed time 5000ms > timeout 3000ms

Counter.add(pid, -8)
Counter.flush(pid)
# 105 due to flush
```
