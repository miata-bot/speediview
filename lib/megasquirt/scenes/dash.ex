defmodule Megasquirt.Scene.Dash do
  use Scenic.Scene
  alias Scenic.Graph
  # import Scenic.Primitives
  import Scenic.Components
  import Megasquirt.Gauge
  alias MegaSquirt.Scene.Settings
  @intro_animation_time 50

  def init(args, opts) do
    viewport = opts[:viewport]
    registry = Keyword.fetch!(args, :registry)

    graph =
      Graph.build()
      |> gauge(:rpm, %{value: 0.0, text: float(0.0)}, translate: {0, 50})
      |> gauge(:map, %{value: 0.0, text: float(0.0)}, translate: {300, 50})
      |> gauge(:afr, %{value: 0.0, text: float(0.0)}, translate: {600, 50})
      |> gauge(:clt, %{value: 0.0, text: float(0.0)}, translate: {0, 200})
      |> gauge(:tps, %{value: 0.0, text: float(0.0)}, translate: {300, 200})
      |> gauge(:adv, %{value: 0.0, text: float(0.0)}, translate: {600, 200})
      |> button("Settings", id: :settings_button, translate: {10, 435})

    {:ok, _} = Registry.register(registry, :dispatch, nil)
    send(self(), {:intro_animation_forward, 0.0})
    {:ok, %{graph: graph, animation_playing: true, viewport: viewport}, push: graph}
  end

  def filter_event({:click, :settings_button}, _from, state) do
    IO.puts("button!")
    Scenic.ViewPort.set_root(state.viewport, {Settings, []})
    {:noreply, state}
  end

  def filter_event(_, _from, state) do
    {:noreply, state, push: state.graph}
  end

  def handle_info({:intro_animation_forward, v}, state) when v >= 1.0 do
    send(self(), {:intro_animation_backward, 1.0})
    {:noreply, state}
  end

  def handle_info({:intro_animation_forward, value}, state) do
    graph =
      state.graph
      |> update_gauge(:rpm, %{value: value, text: float(value * 100)})
      |> update_gauge(:map, %{value: value, text: float(value * 100)})
      |> update_gauge(:afr, %{value: value, text: float(value * 100)})
      |> update_gauge(:clt, %{value: value, text: float(value * 100)})
      |> update_gauge(:tps, %{value: value, text: float(value * 100)})
      |> update_gauge(:adv, %{value: value, text: float(value * 100)})

    Process.send_after(self(), {:intro_animation_forward, value + 0.1}, @intro_animation_time)
    {:noreply, %{state | graph: graph}, push: graph}
  end

  def handle_info({:intro_animation_backward, v}, state) when v <= 0.0 do
    {:noreply, %{state | animation_playing: false}}
  end

  def handle_info({:intro_animation_backward, value}, state) do
    graph =
      state.graph
      |> update_gauge(:rpm, %{value: value, text: float(value * 100)})
      |> update_gauge(:map, %{value: value, text: float(value * 100)})
      |> update_gauge(:afr, %{value: value, text: float(value * 100)})
      |> update_gauge(:clt, %{value: value, text: float(value * 100)})
      |> update_gauge(:tps, %{value: value, text: float(value * 100)})
      |> update_gauge(:adv, %{value: value, text: float(value * 100)})

    Process.send_after(self(), {:intro_animation_backward, value - 0.1}, @intro_animation_time)
    {:noreply, %{state | graph: graph}, push: graph}
  end

  def handle_info({:realtime, data}, %{animation_playing: false} = state) do
    graph =
      state.graph
      |> update_gauge(:rpm, scale_to_gauge(data.rpm, 0.0, 8000.0))
      |> update_gauge(:map, scale_to_gauge(data.map, 0.0, 110.0))
      |> update_gauge(:afr, scale_to_gauge(data.afr1, 0.0, 18.0))
      |> update_gauge(:clt, scale_to_gauge(data.clt, 0.0, 275.0))
      |> update_gauge(:tps, scale_to_gauge(data.tps, 0.0, 100.0))
      |> update_gauge(:adv, scale_to_gauge(data.advance, 0.0, 55.0))

    {:noreply, %{state | graph: graph}, push: graph}
  end

  def handle_info({:realtime, _}, state) do
    {:noreply, state, push: state.graph}
  end

  def float(data) when is_float(data) do
    to_string(:io_lib.format('~.2f', [data]))
  end

  def scale_to_gauge(0, _, _), do: 0

  def scale_to_gauge(value, low, high) do
    x = (value - low) / (high - low)
    scaled = 0.0 + (1.0 - 0.0) * x
    %{value: scaled, text: float(value)}
  end
end
