defmodule Buffered.Counter do
  defmodule Private do
    defstruct last_number: 0, change: 0
  end

  # Interface
  def start_link(
        %{start: start, threshold: threshold, timeout: timeout},
        flush_cb,
        opts \\ []
      ) do
    Buffered.start_link(
      %Buffered.Data{
        identity: 0,
        threshold: threshold,
        timeout: timeout,
        flush_cb: flush_cb,
        private: %Private{
          last_number: start,
          change: 0
        },
        append: fn %Private{change: change} = p, n -> %Private{p | change: change + n} end,
        overflow?: fn %Private{change: change}, threshold -> abs(change) >= threshold end,
        reset: fn %Private{last_number: last_number, change: change} ->
          new_last_number = last_number + change
          {%Private{last_number: new_last_number, change: 0}, [new_last_number]}
        end
      },
      opts
    )
  end

  defdelegate add(pid, change), to: Buffered, as: :append
  defdelegate flush(pid), to: Buffered
end
