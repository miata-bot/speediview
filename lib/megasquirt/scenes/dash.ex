defmodule Megasquirt.Scene.Dash do
  use Scenic.Scene
  alias Scenic.Graph
  import Scenic.Primitives

  def init(args, _opts) do
    registry = Keyword.fetch!(args, :registry)

    graph =
      Graph.build()
      |> gauge_init(100, fill: :white, id: :rpm, translate: {100, 100})
      |> gauge_init(100, fill: :white, id: :map, translate: {400, 100})
      |> gauge_init(100, fill: :white, id: :afr, translate: {700, 100})
      |> gauge_init(100, fill: :white, id: :clt, translate: {100, 350})
      |> gauge_init(100, fill: :white, id: :tps, translate: {400, 350})
      |> gauge_init(100, fill: :white, id: :adv, translate: {700, 350})

    {:ok, _} = Registry.register(registry, :dispatch, nil)
    {:ok, %{graph: graph}, push: graph}
  end

  def handle_info({:realtime, data}, state) do
    graph =
      state.graph
      |> gauge_update(:rpm, data.rpm)
      |> gauge_update(:map, data.map)
      |> gauge_update(:afr, data.afr1)
      |> gauge_update(:clt, data.coolant)
      |> gauge_update(:tps, data.tps)
      |> gauge_update(:adv, data.advance)

    {:noreply, %{state | graph: graph}, push: graph}
  end

  def gauge_update(graph, id, value) do
    Graph.modify(graph, {id, :value}, &text(&1, to_string(value)))
  end

  def gauge_init(graph, radius, opts) do
    value = 0.0
    name = opts[:id]
    {x, y} = from = opts[:translate]

    graph
    |> circle(radius, opts)
    |> line({from, {x + 80, y + 50}}, id: {name, :line}, fill: :red)
    |> text(to_string(name), translate: from, fill: :black, text_align: :center)
    |> text(to_string(value),
      id: {name, :value},
      translate: {x, y + 80},
      fill: :black,
      text_align: :center
    )
  end
end
