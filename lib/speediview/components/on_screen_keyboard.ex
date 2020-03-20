defmodule Speediview.Component.OnScreenKeyboard do
  @moduledoc """
  The Keyboard component provides two styles of keyboard: a full querty keyboard and a numeric pad.

  To use this component in your scene add it to a graph with ScenicUI.Keyboard.add_to_graph/3. You
  can use one of the provided keyboard layouts by passing `:default` or `:num_pad` as the first argument
  or you can call `Keyboard.default/0` or `Keyboard.num_pad/0` to fetch the configuration maps and modify
  specific parameters. The following parameters are configurable on each keyboard:

  * `top` - the y position of the keyboard component, defaults to container bottom - keyboard height
  * `c_width` - container width (by default this is the viewport width)
  * `c_height` - container height (by default this is the viewport height)
  * `btn_width` - defaults to 5% of the container width
  * `btn_height` - the default is calculated from the keyboard height
  * `height` - overall keyboard height
  * `font_size` - button font size
  * `margin` - the margin around each button
  * `style` - style applied to the keyboard component
  * `layout` - a map of keyboard modes (`default` and `shift`) containing keys
  * `btn_style` - a function that gets called for each button allowing custom styles to be applied
  * `transform` - a function called when a button is clicked that allows the button contents to be transformed before being sent in the key event
  """
  use Scenic.Component, has_children: true

  alias Scenic.Graph
  alias Scenic.ViewPort
  # alias Scenic.Primitive.Style.Theme
  import Scenic.Primitives
  import Scenic.Components

  @english_simple %{
    # top: 300,
    # c_width: 500,
    # c_height: 600,
    # btn_width: 20,
    # btn_height: 30,
    height: 180,
    font_size: 18,
    margin: 5,
    style: [fill: {48, 48, 48}],
    layout: %{
      default: [
        ~w(` 1 2 3 4 5 6 7 8 9 0 - = Backspace),
        ~w(Tab q w e r t y u i o p [ ] \\),
        ["Caps Lock"] ++ ~w(a s d f g h j k l ; ' Enter),
        ~w(Shift z x c v b n m , . / Shift),
        ~w(@ Space)
      ],
      shift: [
        ~w(~ ! @ # $ % ^ & * \( \) _ + Backspace),
        ~w(Tab Q W E R T Y U I O P { } |),
        ["Caps Lock"] ++ ~w(A S D F G H J K L : " Enter),
        ~w(Shift Z X C V B N M < > ? Shift),
        ~w(@ Space)
      ]
    },
    btn_style: &__MODULE__.btn_style/2,
    transform: &__MODULE__.transform/1
  }

  @num_pad %{
    font_size: 15,
    layout: %{
      default: [
        ~w(= \( \) Back),
        ~w(Clear / * -),
        ~w(7 8 9 +),
        ~w(4 5 6),
        ~w(1 2 3 Enter),
        ~w(0 .)
      ]
    },
    btn_style: &__MODULE__.num_pad_btn_style/2
  }

  # --------------------------------------------------------
  def info(_data) do
    """
    #{IO.ANSI.red()}The first argument to Keyboard.add_to_graph/2 must be `:default`, `:num_pad`, or a custom map (see Keyboard.default/0)
    #{IO.ANSI.yellow()}
    #{IO.ANSI.default_color()}There are two configuration maps provided that you can modify: Keyboard.default/0 and Keyboard/num_pad/0
    """
  end

  # --------------------------------------------------------
  def verify(:default) do
    {:ok, @english_simple}
  end

  def verify(:num_pad) do
    {:ok, @num_pad}
  end

  def verify(keyboard) when is_map(keyboard), do: {:ok, keyboard}

  def verify(_), do: :invalid_data

  # --------------------------------------------------------
  def init(:default, opts), do: init(@english_simple, opts)
  def init(:num_pad, opts), do: init(@num_pad, opts)

  def init(keyboard, opts) do
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(opts[:viewport])

    keyboard =
      keyboard
      |> Enum.reduce(@english_simple, fn {key, val}, acc -> Map.put(acc, key, val) end)
      |> Map.put_new(:c_width, vp_width)
      |> Map.put_new(:c_height, vp_height)

    keyboard =
      keyboard
      |> Map.put_new(:btn_width, keyboard.c_width * 0.05)
      |> Map.put_new(
        :btn_height,
        (keyboard.height - keyboard.margin) / length(keyboard.layout.default) - keyboard.margin
      )

    state = %{layout: nil, keyboard: keyboard, height: vp_height, width: vp_width}

    layout =
      Enum.reduce(keyboard.layout, %{}, fn {name, layout}, acc ->
        Map.put(acc, name, build_layout(%{state | layout: layout}, name))
      end)

    graph = Map.get(layout, :default)

    state =
      Map.merge(state, %{
        graph: graph,
        layout: layout,
        shift: false,
        caps_lock: false,
        id: opts[:id] || :keyboard
      })

    {:ok, state, push: graph}
  end

  @doc """
  Returns the default configuration map for the querty keyboard
  """
  def default, do: @english_simple

  @doc """
  Returns the default configuration map for the numeric keypad
  """
  def num_pad, do: @num_pad

  def filter_event({:click, btn}, context, %{keyboard: keyboard} = state) do
    filter_event({:key_up, apply(keyboard.transform, [btn])}, context, state)
  end

  def filter_event({:key_up, :caps_lock}, context, %{caps_lock: caps_lock} = state) do
    filter_event({:key_up, :shift}, context, %{state | caps_lock: !caps_lock})
  end

  def filter_event({:key_up, :shift}, _, %{layout: layout, shift: false} = state) do
    graph = layout |> Map.get(:shift)

    {:halt, %{state | graph: graph, shift: true}, push: graph}
  end

  def filter_event({:key_up, :shift}, _, %{layout: layout, shift: true} = state) do
    graph = layout |> Map.get(:default)
    {:halt, %{state | graph: graph, shift: false}, push: graph}
  end

  def filter_event(
        {:key_up, _char} = evt,
        _,
        %{layout: layout, caps_lock: false} = state
      ) do
    graph = layout |> Map.get(:default)

    {:cont, evt, %{state | graph: graph, shift: false}, push: graph}
  end

  def filter_event({:key_up, _} = evt, _, state) do
    {:cont, evt, state}
  end

  defp build_layout(%{keyboard: keyboard, layout: layout}, _selected_layout) do
    Graph.build(
      font_size: keyboard.font_size,
      translate: {0, Map.get(keyboard, :top, keyboard.c_height - keyboard.height)},
      hidden: false
    )
    |> rect({keyboard.c_width, 5}, translate: {0, -5}, fill: :white)
    |> rect({keyboard.c_width, keyboard.height}, keyboard.style)
    |> build_row(layout, keyboard, 0)
  end

  defp build_row(graph, [], _, _), do: graph

  defp build_row(graph, [row | tail], keyboard, top_offset) do
    large_btn_count = Enum.filter(row, &(byte_size(&1) > 1)) |> length()
    small_btn_count = length(row) - large_btn_count

    graph
    |> group(
      fn g ->
        build_btn(g, row, keyboard, 0, large_btn_count, small_btn_count)
      end,
      t: {0, top_offset + keyboard.margin}
    )
    |> build_row(tail, keyboard, top_offset + keyboard.btn_height + keyboard.margin)
  end

  defp build_btn(group, [], _, _, _, _), do: group

  defp build_btn(group, [char | row], keyboard, x, large_btn_count, small_btn_count)
       when byte_size(char) == 1 do
    width = keyboard.btn_width

    default_styles = [
      width: width,
      height: keyboard.btn_height,
      button_font_size: keyboard.font_size,
      theme: :secondary
    ]

    style = apply(keyboard.btn_style, [char, keyboard])
    width = Keyword.get(style, :width, width)

    group
    |> button(char, [id: char, t: {x + keyboard.margin, 0}] ++ default_styles ++ style)
    |> build_btn(row, keyboard, x + width + keyboard.margin, large_btn_count, small_btn_count)
  end

  defp build_btn(group, [char | row], keyboard, x, large_btn_count, small_btn_count) do
    used = (keyboard.btn_width + keyboard.margin) * small_btn_count

    width =
      (keyboard.c_width - used - large_btn_count * keyboard.margin - keyboard.margin) /
        large_btn_count

    default_styles = [
      width: width,
      height: keyboard.btn_height,
      button_font_size: keyboard.font_size,
      theme: :secondary
    ]

    style = apply(keyboard.btn_style, [char, keyboard])
    width = Keyword.get(style, :width, width)

    group
    |> button(char, [id: char, t: {x + keyboard.margin, 0}] ++ default_styles ++ style)
    |> build_btn(row, keyboard, x + width + keyboard.margin, large_btn_count, small_btn_count)
  end

  @doc """
  A callback that allows a button's contents to be transformed before being sent as input
  """
  def transform("Space"), do: " "
  def transform("Tab"), do: "    "
  def transform("Backpace"), do: :backspace
  def transform("Shift"), do: :shift
  def transform("Caps Lock"), do: :caps_lock
  def transform("Enter"), do: :enter
  def transform(char), do: char

  @doc """
  A callback that allows custom styles to be applied to each button.
  """
  def btn_style(_char, _keyboard), do: []

  @doc false
  def num_pad_btn_style("+", keyboard),
    do: [height: keyboard.btn_height * 2 + keyboard.margin, width: keyboard.c_width * 0.05]

  def num_pad_btn_style("Enter", keyboard),
    do: [height: keyboard.btn_height * 2 + keyboard.margin, width: keyboard.c_width * 0.05]

  def num_pad_btn_style("0", keyboard), do: [width: keyboard.c_width * 0.05 * 2 + keyboard.margin]
  def num_pad_btn_style(_char, keyboard), do: [width: keyboard.c_width * 0.05]
end
