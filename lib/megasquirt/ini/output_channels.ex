defmodule Megasquirt.Ini.OutputChannels do
  @moduledoc """
  Responsible for working with the `OutputChannels` portion of an Ini.
  Generates an anon function that is capable of parsing realtime data from
  a device.
  """

  @typedoc "Generated function based on the OutputChannels spec"
  @type decode_realtime_data_fun() :: (bitstring -> map() | :error)

  @doc """
  defines functions for parsing a payload based on the `OutputChannels`
  section of a megasquirt ini file
  """
  @spec gen_decode_realtime_data([IniParser.record()]) :: decode_realtime_data_fun()
  def gen_decode_realtime_data(output_channels) do
    {pattern, pattern_byte_size} = build_pattern(output_channels)
    map_creation_args = build_map_args(pattern, [])

    quoted =
      quote location: :keep do
        fn
          <<unquote_splicing(pattern)>> = _unparsed ->
            Map.new(unquote(map_creation_args))

          _ ->
            :error
        end
      end

    {fun, _} = Code.eval_quoted(quoted)
    {fun, pattern_byte_size}
  end

  # {name, ["scalar", _type, offset, "bit", _mult, _offset]}
  # {name, ["bits", "U08", _expected_offset, {begin_bit, end_bit}]}

  # builds a list of key vaule pairs that look like: [{:key, key}]
  # based on the pattern created in the last step
  defp build_map_args(bitstring_pattern, params)

  # matches underscored variables
  defp build_map_args([{:"::", _meta, [{:_, _, _} | _]} | rest], params) do
    build_map_args(rest, params)
  end

  defp build_map_args([{:"::", _meta, [{_name, var_meta, _} = var | _]} | rest], params) do
    quoted = build_quoted_map_args(var, var_meta[:spec])
    build_map_args(rest, [quoted | params])
  end

  defp build_map_args([_ | rest], params), do: build_map_args(rest, params)

  defp build_map_args([], params), do: Enum.reverse(params)

  # the any() in this spec is lazyness. this function returns a quoted expression,
  # but there's no existing type for quoted in Kernel or Kernel.SpecialForms.
  # TLDR: it takse a quoted variable and  and returns a quoted expression
  @spec build_quoted_map_args({atom(), [any()], atom()}, Ini.record() | nil) :: any()
  defp build_quoted_map_args(
         {name, _meta, _} = var,
         {_key, ["scalar", _type, _offset, _label, mult, offset]}
       )
       when is_number(mult) and is_number(offset) do
    quote location: :keep do
      # TODO(Connor) - i have no idea why i used tuple syntax instad of just +/*
      {unquote(name), unquote({:+, [], [offset, {:*, [], [var, mult]}]})}
    end
  end

  # this will contain {:eval, str} which i don't know what to do with yet.
  # going to be kind of tricky..
  defp build_quoted_map_args({name, _meta, _} = var, _spec) do
    quote location: :keep do
      {unquote(name), unquote(var)}
    end
  end

  # builds a bitstring pattern match
  defp build_pattern(output_channels) do
    {_last_byte_offset, pattern_byte_size} = detect_byte_size(output_channels, 0.0, 0.0)
    build_pattern(0.0, pattern_byte_size, output_channels, [])
  end

  defp build_pattern(current_byte_offset, pattern_byte_size, output_channels, pattern) do
    case find_and_build_quoted(output_channels, current_byte_offset) do
      # end loop when there is no more bytes to create
      {quoted, final_byte_offset} when final_byte_offset >= pattern_byte_size ->
        {Enum.reverse([quoted | pattern]), pattern_byte_size}

      {quoted, next_offset} ->
        build_pattern(next_offset, pattern_byte_size, output_channels, [quoted | pattern])
    end
  end

  defp find_and_build_quoted([{name, ["scalar", "U08", offset | _]} = spec | _], offset) do
    quoted =
      quote location: :keep,
            do: unquote({String.to_atom(name), [spec: spec], nil}) :: unsigned - 8

    {quoted, calculate_offset(offset, "U08")}
  end

  defp find_and_build_quoted([{name, ["scalar", "U16", offset | _]} = spec | _], offset) do
    quoted =
      quote location: :keep,
            do: unquote({String.to_atom(name), [spec: spec], nil}) :: unsigned - 16

    {quoted, calculate_offset(offset, "U16")}
  end

  defp find_and_build_quoted([{name, ["scalar", "U32", offset | _]} = spec | _], offset) do
    quoted =
      quote location: :keep,
            do: unquote({String.to_atom(name), [spec: spec], nil}) :: unsigned - 32

    {quoted, calculate_offset(offset, "U32")}
  end

  defp find_and_build_quoted([{name, ["scalar", "S08", offset | _]} = spec | _], offset) do
    quoted =
      quote location: :keep,
            do: unquote({String.to_atom(name), [spec: spec], nil}) :: unsigned - 8

    {quoted, calculate_offset(offset, "S08")}
  end

  defp find_and_build_quoted([{name, ["scalar", "S16", offset | _]} = spec | _], offset) do
    quoted =
      quote location: :keep,
            do: unquote({String.to_atom(name), [spec: spec], nil}) :: unsigned - 16

    {quoted, calculate_offset(offset, "S16")}
  end

  defp find_and_build_quoted([_unknown | rest], offset) do
    # IO.inspect(unknown, label: "can't turn this into a pattern match spec")
    find_and_build_quoted(rest, offset)
  end

  # if the function couldn't find anything, underscored one byte and move along
  defp find_and_build_quoted([], offset) do
    IO.inspect(offset, label: "Couldn't find a spec for offset")
    quoted = quote location: :keep, do: _ :: unsigned - 8
    {quoted, calculate_offset(offset, "U08")}
  end

  # enumerates the output channels structure and adds the specified number of bytes to the offset in the last record
  defp detect_byte_size(output_channels, byte_offset, byte_size)

  defp detect_byte_size([{_, ["scalar", type, offset | _]} | rest], _, _),
    do: detect_byte_size(rest, offset, calculate_offset(offset, type))

  defp detect_byte_size([{_, ["bits", type, offset | _]} | rest], _, _),
    do: detect_byte_size(rest, offset, calculate_offset(offset, type))

  defp detect_byte_size([_ | rest], offset, size), do: detect_byte_size(rest, offset, size)
  defp detect_byte_size([], offset, size), do: {offset, size}

  defp calculate_offset(offset, "U08"), do: offset + 1
  defp calculate_offset(offset, "U16"), do: offset + 2
  defp calculate_offset(offset, "U32"), do: offset + 4
  defp calculate_offset(offset, "S08"), do: offset + 1
  defp calculate_offset(offset, "S16"), do: offset + 2
  defp calculate_offset(offset, "S32"), do: offset + 4
end
