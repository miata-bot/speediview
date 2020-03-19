defmodule SpeediView.Scene.Dash do
  @moduledoc """
  Root scene for the dash display
  """

  use Scenic.Scene
  alias Scenic.Graph
  import Scenic.Primitives
  # import Scenic.Components

  alias SpeediView.Layout
  import SpeediView.Component.Gauge, only: [gauge: 3]
  import SpeediView.Util

  @version Mix.Project.config()[:version]

  def init(_args, opts) do
    IO.puts("scene init")
    [module_version] = SpeediView.Scene.Dash.module_info(:attributes)[:vsn]
    version_string = "version=#{@version}-#{module_version}"
    viewport = opts[:viewport]

    layout = Layout.load()

    graph =
      Graph.build()
      |> gauge(%{data: 0.0, text: float(0.0)}, id: :rpm, translate: layout[:rpm] || {0, 50})
      |> gauge(%{data: 0.0, text: float(0.0)}, id: :map, translate: layout[:map] || {300, 50})
      |> gauge(%{data: 0.0, text: float(0.0)}, id: :afr, translate: layout[:afr] || {600, 50})
      |> gauge(%{data: 0.0, text: float(0.0)}, id: :clt, translate: layout[:clt] || {0, 200})
      |> gauge(%{data: 0.0, text: float(0.0)}, id: :tps, translate: layout[:tps] || {300, 200})
      |> gauge(%{data: 0.0, text: float(0.0)}, id: :adv, translate: layout[:adv] || {600, 200})
      |> text(version_string, translate: {5, 20})

    {:ok,
     %{
       graph: graph,
       animation_playing: true,
       viewport: viewport,
       picknplace: %{},
       layout: layout,
       selected: nil,
       cursor: {nil, nil}
     }, push: graph}
  end

  def terminate(reason, _state) do
    IO.inspect(reason, label: "dash crash")
  end

  def handle_input({:key, {"down", :release, _}}, _context, %{selected: id} = state)
      when not is_nil(id) do
    info = state.picknplace[state.selected]
    pnp = Map.put(state.picknplace, id, %{info | y: info.y + 10})
    graph = Graph.modify(state.graph, id, &update_opts(&1, translate: {pnp[id].x, pnp[id].y}))
    {:noreply, %{state | picknplace: pnp, graph: graph}, push: graph}
  end

  def handle_input({:key, {"up", :release, _}}, _context, %{selected: id} = state)
      when not is_nil(id) do
    info = state.picknplace[id]
    pnp = Map.put(state.picknplace, id, %{info | y: info.y - 10})
    graph = Graph.modify(state.graph, id, &update_opts(&1, translate: {pnp[id].x, pnp[id].y}))
    {:noreply, %{state | picknplace: pnp, graph: graph}, push: graph}
  end

  def handle_input({:key, {"left", :release, _}}, _context, %{selected: id} = state)
      when not is_nil(id) do
    info = state.picknplace[id]
    pnp = Map.put(state.picknplace, id, %{info | x: info.x - 10})
    graph = Graph.modify(state.graph, id, &update_opts(&1, translate: {pnp[id].x, pnp[id].y}))
    {:noreply, %{state | picknplace: pnp, graph: graph}, push: graph}
  end

  def handle_input({:key, {"right", :release, _}}, _context, %{selected: id} = state)
      when not is_nil(id) do
    info = state.picknplace[id]
    pnp = Map.put(state.picknplace, id, %{info | x: info.x + 10})
    graph = Graph.modify(state.graph, id, &update_opts(&1, translate: {pnp[id].x, pnp[id].y}))
    {:noreply, %{state | picknplace: pnp, graph: graph}, push: graph}
  end

  def handle_input(_event, _context, state) do
    {:noreply, state}
  end

  def filter_event({:down, id, info}, _from, state) do
    IO.puts("pickup: #{id} x=#{info.x} y=#{info.y} pid=#{inspect(info.pid)}")
    pnp = state.picknplace
    pnp = Map.put(pnp, id, info)
    graph = Graph.modify(state.graph, id, &update_opts(&1, scale: 0.90))
    {:noreply, %{state | picknplace: pnp, selected: id, graph: graph}, push: graph}
  end

  def filter_event({:move, id, info}, _from, state) do
    IO.puts("move #{id} x=#{info.x} y=#{info.y}")
    pnp = state.picknplace
    x_diff = info.x - pnp[id].x
    y_diff = info.y - pnp[id].y

    graph =
      Graph.modify(state.graph, id, fn %{transforms: %{translate: {current_x, current_y}}} =
                                         component ->
        update_opts(component, translate: {current_x + x_diff, current_y + y_diff})
      end)

    pnp = Map.put(pnp, id, info)
    {:noreply, %{state | picknplace: pnp, graph: graph}, push: graph}
  end

  def filter_event({:up, id, info}, _from, state) do
    IO.puts("drop #{id} x=#{info.x} y=#{info.y}")
    pnp = state.picknplace
    pnp = Map.put(pnp, id, info)
    %{transforms: %{translate: xy}} = Graph.get!(state.graph, id)
    layout = Map.put(state.layout, id, xy)
    Layout.save(layout)
    graph = Graph.modify(state.graph, id, &update_opts(&1, scale: 1.00))

    {:noreply, %{state | picknplace: pnp, layout: layout, selected: nil, graph: graph},
     push: graph}
  end

  def filter_event(_event, _from, state) do
    # IO.inspect(event, label: "dash event")
    {:noreply, state, push: state.graph}
  end
end
