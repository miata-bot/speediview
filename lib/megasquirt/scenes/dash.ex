defmodule Megasquirt.Scene.Dash do
  use Scenic.Scene
  alias Scenic.Graph
  import Scenic.Primitives

  def init(args, _opts) do
    registry = Keyword.fetch!(args, :registry)

    graph =
      Graph.build()
      |> text("RPM: 0.0", id: :rpm, translate: {80, 80})
      |> text("MAP: 0.0", id: :map, translate: {80, 100})

    {:ok, _} = Registry.register(registry, :dispatch, nil)
    {:ok, %{graph: graph}, push: graph}
  end

  def handle_info({:realtime, data}, state) do
    graph =
      state.graph
      |> Graph.modify(:rpm, &text(&1, "RPM: #{data.rpm}"))
      |> Graph.modify(:map, &text(&1, "MAP: #{data.map}"))

    {:noreply, %{state | graph: graph}, push: graph}
  end
end
