defmodule Megasquirt.MSL.Replay do
  use GenServer
  alias Megasquirt.MSL
  alias Megasquirt.UART.RealtimeData

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    registry = Keyword.fetch!(args, :registry)
    file = Keyword.fetch!(args, :file)
    {:ok, %{times: [], data: [], file: file, registry: registry}, {:continue, :decode}}
  end

  def handle_continue(:decode, state) do
    %{data: data} = MSL.decode(state.file)
    {:noreply, %{state | data: data}, {:continue, :calculate_times}}
  end

  def handle_continue(:calculate_times, state) do
    times =
      state.data
      |> Enum.map(fn(%{"Time" => time}) -> time end)

    send self(), :tick
    {:noreply, %{state | times: times}}
  end

  def handle_info(:tick, %{times: [now, next | times_rest], data: [data | data_rest]} = state) do
    ms = round((next - now) * 1000)
    parsed = RealtimeData.from_msl(data)
    Process.send_after(self(), :tick, ms)

    Registry.dispatch(state.registry, :dispatch, fn entries ->
      for {pid, nil} <- entries, do: send(pid, {:realtime, parsed})
    end)

    {:noreply, %{state | times: [next | times_rest], data: data_rest}}
  end

  def handle_info(:tick, %{times: [now], data: [data]} = state) do
    IO.puts "final tick"
    {:noreply, %{state | times: [], data: []}}
  end
end
