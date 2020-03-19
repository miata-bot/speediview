defmodule SpeediView.Util do
  @doc "Formats a float as a string"
  def float(data) when is_float(data) do
    to_string(:io_lib.format('~.2f', [data]))
  end
end
