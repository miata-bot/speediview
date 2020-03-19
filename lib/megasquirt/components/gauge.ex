defmodule Megasquirt.Component.Gauge do
  import Megasquirt.Util
  alias Scenic.Graph
  alias Scenic.ViewPort
  import Scenic.Primitives
  use Scenic.Component, has_children: false

  @min_rotation -0.3 * :math.pi()
  @max_rotation_travel 0.6 * :math.pi()

  @default_font :roboto
  @default_font_size 20
  @intro_animation_time 50

  def gauge(graph, data, opts) do
    add_to_graph(graph, data, opts)
  end

  @doc false
  def info(data) do
    """
    #{IO.ANSI.red()}Gauge data must be a bitstring: initial_text
    #{IO.ANSI.yellow()}Received: #{inspect(data)}
    #{IO.ANSI.default_color()}
    """
  end

  @doc false
  def verify(arg), do: {:ok, arg}

  def init(data, opts) when is_list(opts) do
    id = opts[:id]
    styles = opts[:styles]

    # font related info
    font = @default_font
    font_size = styles[:button_font_size] || @default_font_size

    # build the graph
    graph =
      Graph.build(font: font, font_size: font_size)
      |> add_gauge(data, id)
      |> add_needle(data, id)

    state = %{
      graph: graph,
      pressed: false,
      contained: false,
      id: id,
      animation_playing: false
    }

    send(self(), {:intro_animation_forward, 0.0})
    # graph = update_gauge(graph, id, %{text: "???", value: 6.9})

    {:ok, state, push: graph}
  end

  def terminate(reason, _state) do
    IO.inspect(reason, label: "guage crash")
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

  # def handle_input(input, _ctx, state) do
  #   IO.inspect(input, label: "input: #{state.id}")
  #   {:noreply, state}
  # end

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

    send_event({:down, state.id, %{x: x, y: y}})
    IO.inspect(down, label: "down")
    ViewPort.capture_input(context, [:cursor_button, :cursor_pos])
    {:noreply, state, push: state.graph}
  end

  def handle_input(
        {:cursor_button, {:left, :release, _, {x, y}}} = left,
        context,
        %{pressed: _pressed, contained: _contained, id: id} = state
      ) do
    IO.inspect(left, label: "up")
    state = Map.put(state, :pressed, false)
    send_event({:up, id, %{x: x, y: y}})
    ViewPort.release_input(context, [:cursor_button, :cursor_pos])
    {:noreply, state, push: state.graph}
  end

  def handle_input({:cursor_pos, {x, y}}, _context, %{pressed: true} = state) do
    send_event({:move, state.id, %{x: x, y: y}})
    {:noreply, state, push: state.graph}
  end

  def handle_input(_event, _context, state) do
    # IO.inspect(event)
    {:noreply, state}
  end

  def handle_info({:intro_animation_forward, v}, state) when v >= 1.0 do
    send(self(), {:intro_animation_backward, 1.0})
    {:noreply, state}
  end

  def handle_info({:intro_animation_forward, value}, state) do
    graph =
      state.graph
      |> update_gauge(state.id, %{value: value, text: float(value * 100)})

    Process.send_after(self(), {:intro_animation_forward, value + 0.1}, @intro_animation_time)
    {:noreply, %{state | graph: graph}, push: graph}
  end

  def handle_info({:intro_animation_backward, v}, state) when v <= 0.0 do
    {:noreply, %{state | animation_playing: false}}
  end

  def handle_info({:intro_animation_backward, value}, state) do
    graph =
      state.graph
      |> update_gauge(state.id, %{value: value, text: float(value * 100)})

    Process.send_after(self(), {:intro_animation_backward, value - 0.1}, @intro_animation_time)
    {:noreply, %{state | graph: graph}, push: graph}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def update_gauge(graph, id, data) do
    clamped = clamp(data[:value])
    rotation = @min_rotation + @max_rotation_travel * clamped

    graph
    |> Graph.modify({id, :needle}, &update_opts(&1, rotate: rotation))
    |> Graph.modify({id, :text}, &text(&1, data[:text]))
  end

  defp add_gauge(group, data, id) do
    group
    |> rrect({200, 150, 6}, stroke: {4, :white})
    |> arc({90, :math.pi() * -0.8, :math.pi() * -0.2}, stroke: {4, :white}, translate: {100, 100})
    |> line({{0, 0}, {8, 8}}, stroke: {6, :white}, translate: {29, 45})
    |> line({{0, 0}, {-8, 8}}, stroke: {6, :white}, translate: {171, 45})
    |> text(data[:text], id: {id, :text}, translate: {75, 50})
    |> text(to_string(id), translate: {150, 100})
  end

  defp add_needle(graph, data, id) do
    clamped = clamp(data[:value])
    rotation = @min_rotation + @max_rotation_travel * clamped
    group(graph, &build_needle/1, id: {id, :needle}, rotate: rotation, translate: {100, 100})
  end

  defp build_needle(group) do
    group
    |> circle(12, fill: {200, 50, 50}, stroke: {1, :white})
    |> triangle({{-8, 0}, {0, -85}, {8, 0}}, fill: {200, 50, 50})
  end

  defp clamp(num) when num <= 0.0, do: 0.0
  defp clamp(num) when num >= 1.0, do: 1.0
  defp clamp(num), do: num

  def scale_to_gauge(0, _, _), do: 0

  def scale_to_gauge(value, low, high) do
    x = (value - low) / (high - low)
    scaled = 0.0 + (1.0 - 0.0) * x
    %{value: scaled, text: float(value)}
  end
end
