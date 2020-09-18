defmodule Buffered.Queue do
  defmodule Private do
    defstruct items: [], filled: 0
  end

  def start_link(%{size: threshold, timeout: timeout}, flush_callback, opts \\ []) do
    Buffered.start_link(
      %Buffered.Data{
        identity: [],
        threshold: threshold,
        timeout: timeout,
        flush_callback: flush_callback,
        private: %Private{
          items: [],
          filled: 0
        },
        append: fn %Private{items: items, filled: filled}, new_items ->
          %Private{items: items ++ new_items, filled: filled + length(new_items)}
        end,
        overflow?: fn %Private{filled: filled}, threshold -> filled >= threshold end,
        reset: fn %Private{items: items} ->
          {%Private{items: [], filled: 0}, [items]}
        end
      },
      opts
    )
  end

  def enqueue(pid, new_items) do
    Buffered.append(pid, new_items)
  end

  def flush(pid) do
    Buffered.flush(pid)
  end
end
