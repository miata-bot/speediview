defmodule Speediview.Secne.ComponentSettings do
  use Scenic.Scene
  alias Scenic.Graph
  import Scenic.Primitives
  # import Scenic.Components

  def init(args, opts) do
    graph =
      Graph.build()
      |> rect({100, 100}, fill: {255, 255, 255, 255})

    viewport = opts[:viewport]

    {:ok, %{graph: graph, viewport: viewport, args: args}, push: graph}
  end

  def filter_event(event, _from, state) do
    IO.inspect(event, label: "settings event")
    {:noreply, state}
  end

  def handle_input({:cursor_button, {:left, :release, _, _}}, _, state) do
    Scenic.ViewPort.set_root(state.viewport, {SpeediView.Scene.Dash, []})
    {:halt, state}
  end

  def handle_input(input, _context, state) do
    IO.inspect(input, label: "settings input")
    {:noreply, state}
  end

  def terminate(reason, _) do
    IO.inspect(reason, label: "Component settings crash")
  end
end
