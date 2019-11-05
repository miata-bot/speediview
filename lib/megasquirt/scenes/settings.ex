defmodule MegaSquirt.Scene.Settings do
  use Scenic.Scene
  alias Scenic.Graph
  import Scenic.Components
  alias MegaSquirt.Scene.Dash

  if Mix.target() == :host do
    @backend Megasquirt.Scenes.Settings.MockBackend
  else
    @backend Megasquirt.Scenes.Settings.VintageNetBackend
  end

  def init(args, opts) do
    viewport = opts[:viewport]
    @backend.subscribe()

    graph =
      Graph.build()
      |> button("Back to dashboard", id: :dash_button, translate: {10, 435})

    {:ok, %{graph: graph, viewport: viewport}, push: graph}
  end

  def filter_event({:click, :dash_button}, _from, state) do
    Scenic.ViewPort.set_root(state.viewport, {Dash, []})
    {:noreply, state}
  end
end
