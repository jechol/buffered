defmodule Buffered do
  @behaviour :gen_statem

  defmodule Data do
    defstruct identity: nil,
              threshold: 0,
              timeout: 0,
              private: %{},
              output_cb: nil,
              # (private, item) -> private
              append: nil,
              # private -> boolean
              overflow?: nil,
              # private -> {private, flush_list}
              reset: nil
  end

  # Interface
  def start_link(%Data{} = data, opts \\ []) do
    :gen_statem.start_link(__MODULE__, data, opts)
  end

  def append(pid, new_item) do
    :gen_statem.call(pid, {:append, new_item})
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
  def handle_event({:call, from}, {:append, identity}, _state, %Data{identity: identity}) do
    # Ignore append identity
    {:keep_state_and_data, {:reply, from, :ok}}
  end

  def handle_event({:call, from}, {:append, new_item}, _, %Data{} = data) do
    {next_state, new_data, flush_list} =
      data
      |> __append(new_item)

    flush_list |> Enum.each(data.output_cb)
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
  defp __append(
         %Data{
           threshold: threshold,
           private: private,
           append: append,
           overflow?: overflow?,
           reset: reset
         } = data,
         new_item
       ) do
    new_private = append.(private, new_item)

    if overflow?.(new_private, threshold) do
      {reset_private, [_ | _] = flush_list} = reset.(new_private)
      {:idle, %Data{data | private: reset_private}, flush_list}
    else
      {:buffering, %Data{data | private: new_private}, []}
    end
  end

  defp __handle_flush_event(%Data{private: private, reset: reset, output_cb: output_cb} = data) do
    {reset_private, flush_list} = reset.(private)
    flush_list |> Enum.each(output_cb)

    {:next_state, :idle, %Data{data | private: reset_private}}
  end
end
