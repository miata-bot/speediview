defmodule Megasquirt.UART.RealtimeData.Tools do
  # okay just try to ignore this file.
  @moduledoc false

  # Compiles a binary pattern match
  defmacro output_channels({:<<>>, _, data} = block) do
    body =
      data
      |> Enum.filter(fn
        {:output_channel, _, _} -> true
        _ -> false
      end)
      |> Enum.map(fn
        # {:output_channel, _, [{name, _, nil} = variable, _signed, _size, "bit", _mult, _offset]} ->
        #   {name, {name, [], [{:<<>>, [], [variable]}]}}

        {:output_channel, _, [{name, _, nil} = variable, _signed, _size, _unit, mult, offset]} ->
          {name, {:+, [], [offset, {:*, [], [variable, mult]}]}}
      end)

    quote location: :keep do
      def parse(unquote(block)) do
        unquote({:%{}, [], List.flatten(body)})
      end
    end
  end

  defmacro output_channel(name, _signed = true, size, _unit, _mult, _offset) do
    quote location: :keep do
      <<unquote(name)::big-integer-signed-size(unquote(size))-unit(1)>>
    end
  end

  defmacro output_channel(name, _signed = false, size, _unit, _mult, _offset) do
    quote location: :keep do
      <<unquote(name)::big-integer-unsigned-size(unquote(size))-unit(1)>>
    end
  end
end
