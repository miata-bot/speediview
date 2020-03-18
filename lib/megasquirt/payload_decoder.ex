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
    {_, output_channels} = List.keyfind(ini, :OutputChannels, 0)

    {pattern, pattern_byte_size} = create_pattern(output_channels)
    map_creation_args = create_map_args(output_channels)

    code =
      quote location: :keep do
        @doc "Decodes a payload based on the ini file"
        @spec decode_payload(<<_::unquote(floor(pattern_byte_size))>>) :: map() | :error
        def decode_payload(<<unquote_splicing(pattern)>> = unparsed) do
          Map.new(unquote(map_creation_args))
        end

        def decode_payload!(_), do: :error
      end

    Macro.to_string(code) |> Code.format_string!() |> IO.puts()
    code
  end

  # takes a list of output channels, validates and creates the args to a bitstring pattern match.
  # if the outputted pattern should look like: << fuel::unsigned-8 >>
  # then this function creates fuel::unsigned-8
  defp create_pattern(output_channels, offset \\ 0.0, acc \\ [])

  # ignore "bit" patterns. They are added via the `create_bitstring_pattern` function
  defp create_pattern(
         [{name, [:scalar, _type, offset, "bit", _mult, _offset]} | rest],
         offset,
         acc
       ) do
    create_pattern(rest, offset, acc)
  end

  # if the offset in state is greater than the channel's expected offset, it's probably a calculation of the
  # last channel with a different name. not sure what to do about this
  defp create_pattern(
         [{_name, [:scalar, _type, expected_offset, _label, _mult, _offset]} | rest],
         actual_offset,
         acc
       )
       when actual_offset > expected_offset do
    create_pattern(rest, actual_offset, acc)
  end

  # unused bits. inject a _::size and increase the iterator
  defp create_pattern(
         [{_name, [:scalar, _, expected_offset, _label, _mult, _offset]} | _] = channels,
         actual_offset,
         acc
       )
       when actual_offset < expected_offset do
    # this may cause issues with bit/byte conversion?
    missing_bytes = expected_offset - actual_offset

    create_pattern(channels, expected_offset, [quote(do: _ :: binary - size(missing_bytes) | acc)])
  end

  defp create_pattern(
         [{name, [:scalar, :U08, offset, _label, _mult, _offset]} | rest],
         offset,
         acc
       ) do
    quoted = quote do: unquote({name, [], nil}) :: unsigned - 8
    create_pattern(rest, offset + 1, [quoted | acc])
  end

  defp create_pattern(
         [{name, [:scalar, :U16, offset, _label, _mult, _offset]} | rest],
         offset,
         acc
       ) do
    quoted = quote do: unquote({name, [], nil}) :: unsigned - 16
    create_pattern(rest, offset + 2, [quoted | acc])
  end

  defp create_pattern(
         [{name, [:scalar, :U32, offset, _label, _mult, _offset]} | rest],
         offset,
         acc
       ) do
    quoted = quote do: unquote({name, [], nil}) :: unsigned - 32
    create_pattern(rest, offset + 4, [quoted, acc])
  end

  defp create_pattern(
         [{name, [:scalar, :S08, offset, _label, _mult, _offset]} | rest],
         offset,
         acc
       ) do
    quoted = quote do: unquote({name, [], nil}) :: signed - 8
    create_pattern(rest, offset + 1, [quoted | acc])
  end

  defp create_pattern(
         [{name, [:scalar, :S16, offset, _label, _mult, _offset]} | rest],
         offset,
         acc
       ) do
    quoted = quote do: unquote({name, [], nil}) :: signed - 16
    create_pattern(rest, offset + 2, [quoted | acc])
  end

  # bits has to branch off to create a sub bitstring. when it completes, it finishes the create_pattern loop
  defp create_pattern([{_name, [:bits | _]} | _] = output_channels, offset, acc) do
    IO.inspect(hd(acc), label: "last value")

    {bitstring_pattern, rest, num_bytes} =
      create_bitstring_pattern(output_channels, offset, 0, [])

    quoted =
      quote location: :keep do
        <<unquote_splicing(bitstring_pattern), _::bitstring>>
      end

    create_pattern(rest, offset + num_bytes, [quoted | acc])
  end

  defp create_pattern([{_name, [:scalar | _]} = output_channel | _rest], offset, _acc) do
    raise("Unknown scalar output channel. patern: #{inspect(output_channel)}, offset=#{offset}")
  end

  defp create_pattern([unknown | rest], offset, acc) do
    IO.inspect(unknown, label: "unknown output channel")
    create_pattern(rest, offset, acc)
  end

  defp create_pattern([], offset, acc) do
    {Enum.reverse(acc), offset}
  end

  defp create_bitstring_pattern(
         [{_, [:bits, :U08, _expected_offset, _]} | _] = channels,
         actual_offset,
         bits_counted,
         acc
       )
       when bits_counted >= 8 do
    IO.puts("counted #{bits_counted} bits")
    create_bitstring_pattern(channels, actual_offset + 1, 0, acc)
  end

  # problem: tunerstudio ini files list multi byte bit specs little endian?
  # solution: enumerate and fix?
  defp create_bitstring_pattern(
         [{_, [:bits, :U08, expected_offset, _]} | _] = channels,
         actual_offset,
         bits_counted,
         acc
       )
       when actual_offset < expected_offset do
    IO.puts("fixing little endian thing: expected=#{expected_offset} actual=#{actual_offset}")

    {bits, rest} =
      Enum.reduce(channels, {[], []}, fn
        {_, [:bits, :U08, _, _]} = channel, {bits, []} ->
          {bits ++ [channel], []}

        not_bits, {bits, list_of_not_bits} ->
          {bits, list_of_not_bits ++ [not_bits]}
      end)

    bits =
      Enum.sort(bits, fn
        {_, [:bits, :U08, offset1, _]}, {_, [:bits, :U08, offset2, _]} ->
          offset1 <= offset2
      end)

    create_bitstring_pattern(bits ++ rest, actual_offset, bits_counted, acc)
  end

  defp create_bitstring_pattern(
         [{name, [:bits, :U08, offset, {first_bit, last_bit}]} | rest],
         offset,
         bits_counted,
         acc
       ) do
    IO.inspect(name, label: "#{offset}")
    bit_size = floor(last_bit - first_bit) + 1

    quoted =
      quote location: :keep do
        unquote({name, [], nil}) :: integer - size(unquote(bit_size))
      end

    create_bitstring_pattern(rest, offset, bits_counted + bit_size, [quoted | acc])
  end

  defp create_bitstring_pattern(
         [{_name, [:bits | _]} = output_channel | _rest],
         offset,
         _bits_counted,
         _acc
       ) do
    raise("Unknown bits output channel. patern: #{inspect(output_channel)}, offset=#{offset}")
  end

  # anything else triggers sub bitstring completion. back to create_pattern
  defp create_bitstring_pattern(output_channels, offset, _number_of_bits, acc) do
    IO.inspect(offset, label: "offset after creating bitstring pattern")
    number_of_bits = Enum.count(acc)

    if number_of_bits > 8 do
      # round up to 2 bytes, 16 bits
      {Enum.reverse(acc), output_channels, 2}
    else
      # round up to 1 byte, 8 bits
      {Enum.reverse(acc), output_channels, 1}
    end
  end

  # Creates a list of key/value pairs for variable asignment.
  # This is used as the arguments to `Map.new/1`. 
  # if the call looks like Map.new([fuel: fuel]) or Map.new([{:fuel, fuel}])
  # then this function creates: [fuel: fuel] or [{:fuel, fuel}]
  # this function also should evaluate the function of converting the raw number into it's consumable value
  # issue: tunerstudio applies an evaluation on some of the values which is not implemented here. This will cause 
  # these values to fail irl.
  # note these "eval" tuples don't have a specified language and they must be evaluated at runtime..
  defp create_map_args(output_channels, acc \\ [])

  # ignore "bit" patterns. They aren't assigned in the pattern
  defp create_map_args([{name, [:scalar, _type, _offset, "bit", mult, offset]} | rest], acc) do
    create_map_args(rest, acc)
  end

  defp create_map_args([{name, [:scalar, _type, _offset, label, mult, offset]} | rest], acc) do
    if label == "bit", do: raise("??")

    quoted =
      quote location: :keep do
        {unquote(name), unquote({name, [], nil}) * unquote(mult) + unquote(offset)}
      end

    create_map_args(rest, [quoted | acc])
  end

  defp create_map_args([{name, [:bits, :U08 | _]} | rest], acc) do
    quoted =
      quote location: :keep do
        {unquote(name), unquote({name, [], nil})}
      end

    create_map_args(rest, [quoted | acc])
  end

  defp create_map_args([unknown | rest], acc) do
    IO.inspect(unknown, label: "unknown pattern")
    create_map_args(rest, acc)
  end

  defp create_map_args([], acc), do: Enum.reverse(acc)
end
