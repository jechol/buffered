defmodule Buffered.Queue do
  @behaviour :gen_statem

  defmodule Data do
    defstruct items: [], filled: 0, threshold: 0, timeout: 0, flush_callback: nil
  end

  # Interface
  def start_link(%{size: threshold, timeout: timeout}, flush_callback, opts \\ []) do
    :gen_statem.start_link(
      __MODULE__,
      %Data{threshold: threshold, timeout: timeout, flush_callback: flush_callback},
      opts
    )
  end

  def enqueue(pid, new_items) do
    :gen_statem.call(pid, {:enqueue, new_items})
  end

  def flush(pid) do
    :gen_statem.call(pid, :flush)
  end

  # Callbacks
  def callback_mode() do
    [:handle_event_function, :state_enter]
  end

  def init(data) do
    {:ok, :idle, data}
  end

  # State callbacks
  def handle_event({:call, from}, {:enqueue, []}, _state, _buffer) do
    # Ignore void enqueue
    {:keep_state_and_data, {:reply, from, :ok}}
  end

  def handle_event({:call, from}, {:enqueue, new_items}, _, %Data{} = data) do
    {next_state, new_data, flush_list} =
      data
      |> __enqueue(new_items)

    flush_list |> Enum.each(data.flush_callback)
    {:next_state, next_state, new_data, {:reply, from, :ok}}
  end

  def handle_event({:call, from}, :flush, _, %Data{} = data) do
    __handle_flush_event(data) |> Tuple.append({:reply, from, :ok})
  end

  def handle_event(:enter, :idle, :buffering, %Data{timeout: timeout}) do
    {:keep_state_and_data, {:state_timeout, timeout, :flush}}
  end

  def handle_event(:enter, _, :idle, _) do
    :keep_state_and_data
  end

  def handle_event(:state_timeout, :flush, :buffering, %Data{} = data) do
    __handle_flush_event(data)
  end

  # Private
  defp __enqueue(%Data{} = data, new_items) when is_list(new_items) do
    new_buffer_filled = length(new_items) + data.filled

    if new_buffer_filled >= data.threshold do
      {:idle, %Data{data | items: [], filled: 0}, [data.items ++ new_items]}
    else
      {:buffering, %Data{data | items: data.items ++ new_items, filled: new_buffer_filled}, []}
    end
  end

  defp __handle_flush_event(%Data{} = data) do
    data.flush_callback.(data.items)

    {:next_state, :idle, %Data{data | items: [], filled: 0}}
  end
end
