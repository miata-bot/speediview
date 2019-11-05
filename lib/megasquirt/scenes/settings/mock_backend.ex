defmodule Megasquirt.Scenes.Settings.MockBackend do
  @behaviour Megasquirt.Scenes.Settings.Backend
  use GenServer

  def subscribe(pid) do
    GenServer.call(__MODULE__, {:subscribe, pid})
  end

  def dispatch(msg) do
    GenServer.call(__MODULE__, {:dispatch, msg})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    {:ok, %{subscriber: nil}}
  end

  @impl GenServer
  def handle_call({:subscribe, pid}, _from, state) do
    {:reply, :ok, %{subscriber: pid}}
  end

  def handle_call({:dispatch, msg}, _from, %{subscriber: nil} = state) do
    {:reply, :ok, state}
  end

  def handle_call({:dispatch, msg}, _from, state) do
    send(state.subscriber, msg)
    {:reply, :ok, state}
  end
end
