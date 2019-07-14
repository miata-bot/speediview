defmodule Megasquirt.RealtimeParser.Tools do
  defmacro field(name, _signed = true, size) do
    quote do
      <<unquote(name)::big-integer-signed-size(unquote(size))-unit(1)>>
    end
  end

  defmacro field(name, _signed = false, size) do
    quote do
      <<unquote(name)::big-integer-unsigned-size(unquote(size))-unit(1)>>
    end
  end
end
