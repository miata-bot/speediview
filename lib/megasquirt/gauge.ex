defmodule Megasquirt.Gauge do
  import Scenic.Primitives
  alias Scenic.Graph

  @min_rotation -0.3 * :math.pi()
  @max_rotation_travel 0.6 * :math.pi()

  def gauge(graph, id, data, opts) do
    opts = Keyword.merge(opts, id: id)
    group(graph, &build_group(&1, data, opts), opts)
  end

  def update_gauge(graph, id, data) do
    clamped = clamp(data[:value])
    rotation = @min_rotation + @max_rotation_travel * clamped

    graph
    |> Graph.modify({id, :needle}, &update_opts(&1, rotate: rotation))
    |> Graph.modify({id, :text}, &text(&1, data[:text]))
  end

  defp build_group(graph, data, opts) do
    graph
    |> add_gauge(data, opts)
    |> add_needle(data, opts)
  end

  defp add_gauge(group, data, opts) do
    group_id = Keyword.fetch!(opts, :id)

    group
    |> arc({90, :math.pi() * -0.8, :math.pi() * -0.2}, stroke: {4, :white}, translate: {100, 100})
    |> line({{0, 0}, {8, 8}}, stroke: {6, :white}, translate: {29, 45})
    |> line({{0, 0}, {-8, 8}}, stroke: {6, :white}, translate: {171, 45})
    |> text(data[:text], id: {group_id, :text}, translate: {75, 50})
    |> text(to_string(group_id), translate: {150, 100})
  end

  defp add_needle(graph, data, opts) do
    clamped = clamp(data[:value])
    rotation = @min_rotation + @max_rotation_travel * clamped
    group_id = Keyword.fetch!(opts, :id)

    group(graph, &build_needle/1, id: {group_id, :needle}, rotate: rotation, translate: {100, 100})
  end

  defp build_needle(group) do
    group
    |> circle(12, fill: {200, 50, 50}, stroke: {1, :white})
    |> triangle({{-8, 0}, {0, -85}, {8, 0}}, fill: {200, 50, 50})
  end

  defp clamp(num) when num <= 0.0, do: 0.0
  defp clamp(num) when num >= 1.0, do: 1.0
  defp clamp(num), do: num
end
