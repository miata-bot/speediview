defmodule SpeediViewUI.Component.Template do
  alias Scenic.Graph
  alias Scenic.ViewPort
  import Scenic.Primitives, warn: false
  use Scenic.Component, has_children: false

  @doc false
  def info(data) do
    """
    #{IO.ANSI.red()} Component data
    #{IO.ANSI.yellow()}Received: #{inspect(data)}
    #{IO.ANSI.default_color()}
    """
  end

  @doc false
  def verify(arg), do: {:ok, arg}

  def init(_data, opts) when is_list(opts) do
    id = opts[:id]
    styles = opts[:styles]
    viewport = opts[:viewport]
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)
    graph = Graph.build()

    state = %{
      viewport: viewport,
      vp_height: vp_height,
      vp_width: vp_width,
      styles: styles,
      graph: graph,
      id: id
    }

    {:ok, state, push: graph}
  end

  def handle_input(input, _context, state) do
    IO.inspect(input, label: "#{__MODULE__} unhandled input")
    {:noreply, state}
  end

  def handle_event(event, _from, state) do
    IO.inspect(event, label: "#{__MODULE__} unhandled event")
    {:noreply, state}
  end
end
