defmodule Megasquirt.UART do
  use GenServer
  require Logger
  alias Circuits.UART
  alias Megasquirt.UART.RealtimeData

  def start_link(args, opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init(args) do
    tty = Keyword.fetch!(args, :tty)
    registry = Keyword.fetch!(args, :registry)
    {:ok, uart} = UART.start_link()
    send(self(), :open)
    {:ok, %{uart: uart, status: :needs_open, tty: tty, registry: registry}}
  end

  def handle_info(:open, %{status: :needs_open} = state) do
    case UART.open(state.uart, state.tty,
           speed: 115_200,
           active: true
         ) do
      :ok ->
        send(self(), :get_realtime_data)
        {:noreply, %{state | status: :open}}

      error ->
        Logger.error("Failed to open uart: #{inspect(error)}")
        Process.send_after(self(), :open, 5000)
        {:noreply, state}
    end
  end

  def handle_info(:get_realtime_data, %{status: :open} = state) do
    data = <<0, 1, "A">>
    write = data <> <<:erlang.crc32("A")::big-integer-size(32)>>

    case UART.write(state.uart, write) do
      :ok ->
        {:noreply, state, 1000}

      error ->
        Logger.error("Failed to write data: #{inspect(data)} #{inspect(error)}")
        Process.send_after(self(), :get_realtime_data, 100)
        {:noreply, state}
    end
  end

  def handle_info({:circuits_uart, _tty, {:error, error}}, state) do
    Logger.error("TTY error (closed): #{inspect(error)}")
    :ok = Circuits.UART.close(state.uart)
    {:ok, uart} = UART.start_link()
    Process.send_after(self(), :open, 1000)
    {:noreply, %{state | status: :needs_open, uart: uart}}
  end

  def handle_info({:circuits_uart, _, <<_::big-integer-size(16), 0x01, data::binary>>}, state) do
    parsed = RealtimeData.parse(data)

    Registry.dispatch(state.registry, :dispatch, fn entries ->
      for {pid, nil} <- entries, do: send(pid, {:realtime, parsed})
    end)

    Process.send_after(self(), :get_realtime_data, 100)
    {:noreply, state}
  end

  def handle_info(:timeout, %{status: :open} = state) do
    Logger.warn("Timeout waiting for response. Trying again")
    send(self(), :get_realtime_data)
    {:noreply, state}
  end

  def handle_info(data, state) do
    _ = inspect(data)
    # Logger.error """
    # Unknown data: #{inspect(data, limit: :infinity)}
    # for state: #{state.status}
    # """
    {:noreply, state}
  end
end
