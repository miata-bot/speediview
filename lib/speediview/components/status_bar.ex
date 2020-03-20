defmodule SpeediView.Component.StatusBar do
  alias Scenic.Graph
  alias Scenic.ViewPort
  import Scenic.Primitives
  use Scenic.Component, has_children: false

  @default_font :roboto
  @default_font_size 20
  @default_panel_height 180
  @default_bar_height 15

  def status_bar(graph, data, opts) do
    add_to_graph(graph, data, opts)
  end

  @doc false
  def info(data) do
    """
    #{IO.ANSI.red()}Status Bar
    #{IO.ANSI.yellow()}Received: #{inspect(data)}
    #{IO.ANSI.default_color()}
    """
  end

  @doc false
  def verify(arg), do: {:ok, arg}

  def init(_data, opts) when is_list(opts) do
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(opts[:viewport])

    id = opts[:id]
    styles = opts[:styles]

    # font related info
    font = @default_font
    font_size = styles[:button_font_size] || @default_font_size

    # build the graph
    graph =
      Graph.build(font: font, font_size: font_size)
      |> group(&build_panel(&1, {vp_width, vp_height}), id: :pannel_group)
      |> rrect({vp_width, @default_bar_height, 6}, id: :bar_handle, fill: {255, 255, 255, 200})
      |> rrect({floor(vp_width / 4), floor(@default_bar_height / 2), 6},
        fill: {51, 51, 51, 255},
        translate: {
          # half of the viewport width, shifted half of the bar width
          floor(vp_width / 2 - vp_width / 4 / 2),
          # half of the bar height, shifted by half of the handle height
          floor(@default_bar_height / 2 - @default_bar_height / 6)
        }
      )

    state = %{
      graph: graph,
      contained: false,
      vp_height: vp_height,
      vp_width: vp_height,
      viewport: opts[:viewport],
      id: id,
      pressed: false
    }

    {:ok, state, push: graph}
  end

  def build_panel(group, {vp_width, _vp_height}) do
    group
    |> rect({vp_width, @default_panel_height},
      id: :panel,
      fill: {90, 92, 91, 250},
      translate: {0, -180}
    )
    |> text("epstein didn't kill himself",
      scale: 4.0,
      translate: {floor(vp_width / 2), -1 * floor(@default_panel_height / 2)},
      text_align: :center
    )
  end

  def terminate(reason, _state) do
    IO.inspect(reason, label: "status bar crash")
  end

  @doc false
  def handle_input(
        {:cursor_enter, _uid},
        _context,
        %{
          pressed: true
        } = state
      ) do
    state = Map.put(state, :contained, true)
    {:noreply, state, push: state.graph}
  end

  def handle_input(
        {:cursor_exit, _uid},
        _context,
        %{
          pressed: true
        } = state
      ) do
    state = Map.put(state, :contained, false)
    {:noreply, state, push: state.graph}
  end

  def handle_input(down = {:cursor_button, {:left, :press, _, {x, y}}}, context, state) do
    state =
      state
      |> Map.put(:pressed, true)
      |> Map.put(:contained, true)

    send_event({:down, state.id, %{pid: self(), x: x, y: y}})
    IO.inspect(down, label: "down")
    ViewPort.capture_input(context, [:cursor_button, :cursor_pos])
    graph = Graph.modify(state.graph, :container, &update_opts(&1, fill: {255, 255, 255, 40}))
    {:noreply, %{state | graph: graph}, push: graph}
  end

  def handle_input(
        {:cursor_button, {:left, :release, _, {x, y}}} = left,
        context,
        %{pressed: _pressed, contained: _contained, id: id} = state
      ) do
    IO.inspect(left, label: "up")
    state = Map.put(state, :pressed, false)
    send_event({:up, id, %{pid: self(), x: x, y: y}})
    ViewPort.release_input(context, [:cursor_button, :cursor_pos])
    graph = Graph.modify(state.graph, :container, &update_opts(&1, fill: {255, 255, 255, 0}))
    {:noreply, %{state | graph: graph}, push: graph}
  end

  def handle_input({:cursor_pos, {x, y}}, _context, %{pressed: true} = state) do
    send_event({:move, state.id, %{pid: self(), x: x, y: y}})
    {:noreply, state, push: state.graph}
  end

  def handle_input(_event, _context, state) do
    # IO.inspect(event)
    {:noreply, state}
  end
end
