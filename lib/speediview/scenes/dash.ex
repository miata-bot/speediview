defmodule SpeediView.Scene.Dash do
  @moduledoc """
  Root scene for the dash display
  """

  use Scenic.Scene
  alias Scenic.Graph
  alias Scenic.ViewPort
  import Scenic.Primitives

  alias SpeediView.Layout
  import SpeediView.Component.Gauge, only: [gauge: 3]
  import SpeediView.Component.StatusBar, only: [status_bar: 3]
  import SpeediView.Util

  def init(_args, opts) do
    IO.puts("scene init")
    viewport = opts[:viewport]
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)
    layout = Layout.load()

    graph =
      Graph.build()
      |> rect({vp_width, vp_height}, id: :background, fill: {51, 51, 51}, stroke: {2, :white})
      |> gauge(%{data: 0.0, text: float(0.0)}, id: :rpm, translate: layout[:rpm] || {0, 50})
      |> gauge(%{data: 0.0, text: float(0.0)}, id: :map, translate: layout[:map] || {300, 50})
      |> gauge(%{data: 0.0, text: float(0.0)}, id: :afr, translate: layout[:afr] || {600, 50})
      |> gauge(%{data: 0.0, text: float(0.0)}, id: :clt, translate: layout[:clt] || {0, 200})
      |> gauge(%{data: 0.0, text: float(0.0)}, id: :tps, translate: layout[:tps] || {300, 200})
      |> gauge(%{data: 0.0, text: float(0.0)}, id: :adv, translate: layout[:adv] || {600, 200})
      |> status_bar(%{}, id: :status_bar, translate: {0, 0})
      |> group(
        fn graph ->
          rrect(graph, {400, 180, 10},
            fill: :red,
            stroke: {5, :white},
            translate: {floor(vp_width / 2) - 200, 150}
          )
          |> text(
            """
            DANGER TO
            MANIFOLD
            """,
            translate: {400, 220},
            text_align: :center,
            scale: 3.5
          )
        end,
        id: :danger_to_manifold,
        hidden: true
      )

    {:ok,
     %{
       graph: graph,
       animation_playing: true,
       viewport: viewport,
       picknplace: %{},
       layout: layout,
       selected: nil,
       cursor: {nil, nil},
       vp_width: vp_width,
       vp_height: vp_height
     }, push: graph}
  end

  def terminate(reason, _state) do
    IO.inspect(reason, label: "dash crash")
  end

  def handle_input(_input, _context, state) do
    # IO.inspect(input, label: "dash input")
    {:noreply, state}
  end

  # status bar pull up
  def filter_event({:down, id = :status_bar, info}, _from, state) do
    # IO.puts("pickup: #{id} x=#{info.x} y=#{info.y} pid=#{inspect(info.pid)}")
    pnp = state.picknplace
    pnp = Map.put(pnp, id, info)
    {:noreply, %{state | picknplace: pnp, selected: id}, push: state.graph}
  end

  def filter_event({:move, id = :status_bar, info}, _from, state) do
    # IO.puts("status bar move #{id} x=#{info.x} y=#{info.y}")
    pnp = state.picknplace
    y_diff = info.y - pnp[id].y

    graph =
      Graph.modify(state.graph, id, fn %{transforms: %{translate: {current_x, current_y}}} =
                                         component ->
        new_y = current_y + y_diff

        case new_y do
          new_y when new_y > 180 ->
            component

          new_y when new_y < 0 ->
            component

          new_y ->
            update_opts(component, translate: {current_x, new_y})
        end
      end)

    pnp = Map.put(pnp, id, info)
    {:noreply, %{state | picknplace: pnp, graph: graph}, push: graph}
  end

  def filter_event({:up, id = :status_bar, info}, _from, state) do
    # IO.puts("drop #{id} x=#{info.x} y=#{info.y}")
    pnp = state.picknplace
    pnp = Map.put(pnp, id, info)
    {:noreply, %{state | picknplace: pnp, selected: nil}, push: state.graph}
  end

  # / status bar pull up

  # gauge movement 
  # def filter_event({:long_press, id, _info}, _from, state) do
  #   # IO.puts("long press: #{id}")

  #   :ok =
  #     Scenic.ViewPort.set_root(
  #       state.viewport,
  #       {Speediview.Secne.ComponentSettings, [back: self()]}
  #     )

  #   {:halt, state}
  # end

  def filter_event({:down, id, info}, _from, state) do
    # IO.puts("pickup: #{id} x=#{info.x} y=#{info.y} pid=#{inspect(info.pid)}")
    pnp = state.picknplace
    pnp = Map.put(pnp, id, info)
    graph = Graph.modify(state.graph, id, &update_opts(&1, scale: 0.90))
    {:noreply, %{state | picknplace: pnp, selected: id, graph: graph}, push: graph}
  end

  # TODO(Connor) add collision detection with the edges of the windows here
  def filter_event({:move, id, info}, _from, state) do
    # IO.puts("move #{id} x=#{info.x} y=#{info.y}")
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
    # IO.puts("drop #{id} x=#{info.x} y=#{info.y}")
    pnp = state.picknplace
    pnp = Map.put(pnp, id, info)
    %{transforms: %{translate: xy}} = Graph.get!(state.graph, id)
    layout = Map.put(state.layout, id, xy)
    Layout.save(layout)
    graph = Graph.modify(state.graph, id, &update_opts(&1, scale: 1.00))

    {:noreply, %{state | picknplace: pnp, layout: layout, selected: nil, graph: graph},
     push: graph}
  end

  # /gauge movement

  def filter_event({:gauge_value, :map, value}, _, state) do
    graph =
      if value >= 0.90 do
        Graph.modify(state.graph, :danger_to_manifold, &update_opts(&1, hidden: false))
      else
        Graph.modify(state.graph, :danger_to_manifold, &update_opts(&1, hidden: true))
      end

    {:noreply, %{state | graph: graph}, push: graph}
  end

  def filter_event(event, _from, state) do
    IO.inspect(event, label: "dash event")
    {:noreply, state, push: state.graph}
  end
end
