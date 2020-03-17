defmodule Megasquirt.PayloadDecoder do
  alias Megasquirt.IniParser

  @doc """
  defines functions for parsing a payload based on the `OutputChannels`
  section of a megasquirt ini file. Example:

    defmodule Megasquirt.MS3PayloadDecoder do
      # this will cause the file to be recompiled if the ini file changes
      @external_file "ms3.ini"
      use Megasquirt.PayloadDecoder, ini: "ms3.ini"
    end
  """
  defmacro __using__(opts) do
    ini_filename = Keyword.fetch!(opts, :ini)
    ini = IniParser.parse_file(ini_filename)
    {_, output_channels} = List.keyfind(ini, "OutputChannels", 0)

    parsable =
      Enum.filter(output_channels, fn
        {_name, ["scalar" | _]} -> true
        _ -> false
      end)

    sub_parsable = extract_sub_parsable(output_channels)

    pattern =
      Enum.map(parsable, fn
        {name, ["scalar", "U08", _index, _label, _mult, _offset]} ->
          quote do: unquote({String.to_atom(name), [], nil}) :: unsigned - 8

        {name, ["scalar", "U16", _index, _label, _mult, _offset]} ->
          quote do: unquote({String.to_atom(name), [], nil}) :: unsigned - 16

        {name, ["scalar", "U32", _index, _label, _mult, _offset]} ->
          quote do: unquote({String.to_atom(name), [], nil}) :: unsigned - 32

        {name, ["scalar", "S08", _index, _label, _mult, _offset]} ->
          quote do: unquote({String.to_atom(name), [], nil}) :: signed - 8

        {name, ["scalar", "S16", _index, _label, _mult, _offset]} ->
          quote do: unquote({String.to_atom(name), [], nil}) :: signed - 16

        {_name, ["scalar", type, _index, _label, _mult, _offset]} ->
          raise "unknown scalar type: #{type}"
      end)

    map_arg =
      Enum.map(parsable, fn
        {name, ["scalar", _type, _index, _label, mult, offset]} ->
          {mult, ""} = Float.parse(mult)
          {offset, ""} = Float.parse(offset)

          quote location: :keep,
                do: {
                  unquote(String.to_atom(name)),
                  unquote({String.to_atom(name), [], nil}) * unquote(mult) + unquote(offset)
                }
      end)

    quote location: :keep do
      @doc "Decodes a payload based on the ini file"
      def decode_payload!(<<unquote_splicing(pattern)>>) do
        Map.new(unquote(map_arg))
      end
    end
  end

  defp extract_sub_parsable(output_channels, acc \\ [])

  defp extract_sub_parsable([{name, ["scalar", _type, _index, "\"bit\"", _, _]} | rest], acc) do
    {spec, rest} = do_extract_sub_parsable(name, rest)
    extract_sub_parsable(rest, [{name, spec} | acc])
  end

  defp extract_sub_parsable([_ | rest], acc) do
    extract_sub_parsable(rest, acc)
  end

  defp extract_sub_parsable([], acc), do: acc

  defp do_extract_sub_parsable(channel_name, output_channels, acc \\ [])

  defp do_extract_sub_parsable(channel_name, [{name, ["bits" | _] = spec} | rest], acc) do
    do_extract_sub_parsable(channel_name, rest, [{name, spec} | acc])
  end

  defp do_extract_sub_parsable(_channel_name, [_ | _] = rest, acc) do
    # positions = Enum.reverse(acc)
    # |> Enum.map(fn 
    #   {name, ["bits", _type, _index, pos]} ->
    #     <<"[", num::binary-1, ":", num::binary-1, "]">> = pos

    #     {String.to_integer(num), name}
    # end)

    {Enum.reverse(acc), rest}
  end
end
