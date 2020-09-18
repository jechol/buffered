defmodule BufferedCounter do
  @behaviour :gen_statem

  defmodule Counter do
    defstruct number: 0, change: 0, threshold: 0, timeout: 0, flush_callback: nil
  end

  # Interface
  def start_link(
        %{start: start, threshold: threshold, timeout: timeout},
        flush_callback,
        opts \\ []
      ) do
    :gen_statem.start_link(
      __MODULE__,
      %Counter{
        number: start,
        threshold: threshold,
        timeout: timeout,
        flush_callback: flush_callback
      },
      opts
    )
  end

  def add(pid, change) do
    :gen_statem.call(pid, {:add, change})
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
  def handle_event({:call, from}, {:add, 0}, _state, _buffer) do
    # Ignore void add
    {:keep_state_and_data, {:reply, from, :ok}}
  end

  def handle_event({:call, from}, {:add, num_to_add}, _, %Counter{} = counter) do
    {next_state, new_counter, flush_list} =
      counter
      |> __add(num_to_add)

    flush_list |> Enum.each(counter.flush_callback)
    {:next_state, next_state, new_counter, {:reply, from, :ok}}
  end

  def handle_event({:call, from}, :flush, _, %Counter{} = counter) do
    __handle_flush_event(counter) |> Tuple.append({:reply, from, :ok})
  end

  def handle_event(:enter, :idle, :buffering, %Counter{timeout: timeout}) do
    {:keep_state_and_data, {:state_timeout, timeout, :flush}}
  end

  def handle_event(:enter, _, :idle, _) do
    :keep_state_and_data
  end

  def handle_event(:state_timeout, :flush, :buffering, %Counter{} = counter) do
    __handle_flush_event(counter)
  end

  # Private
  defp __add(%Counter{} = counter, num_to_add) when is_number(num_to_add) and num_to_add != 0 do
    new_change = counter.change + num_to_add

    if abs(new_change) >= counter.threshold do
      new_number = counter.number + new_change
      {:idle, %Counter{counter | number: new_number, change: 0}, [new_number]}
    else
      {:buffering, %Counter{counter | change: new_change}, []}
    end
  end

  defp __handle_flush_event(%Counter{} = counter) do
    new_number = counter.number + counter.change
    counter.flush_callback.(new_number)
    {:next_state, :idle, %Counter{counter | number: new_number, change: 0}}
  end
end
