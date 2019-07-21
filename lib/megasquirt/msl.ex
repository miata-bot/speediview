defmodule Megasquirt.MSL do
  alias Megasquirt.MSL
  defstruct [:format, :capture_date, :fields, :data]

  def decode(file) do
    File.read!(file)
    |> String.split("\n")
    |> header()
  end

  def header([format, capture_date, fields | data]) do
    fields = fields(fields)
    %MSL{
      format: String.trim(format, "\""),
      capture_date: String.trim(capture_date, "\""),
      fields: fields,
      data: data(fields, data)
    }
  end

  def fields(fields) do
    String.split(fields, "\t")
  end

  def data(fields, data, acc \\ [])

  def data(fields, [field | rest], acc) do
    values =
      field
      |> String.split("\t")
      |> Enum.map(fn value ->
        case Float.parse(value) do
          {float, ""} -> float
          :error -> value
        end
      end)

    data(fields, rest, [Map.new(Enum.zip(fields, values)) | acc])
  end

  def data(_fields, [], acc) do
    Enum.reverse(acc)
  end
end
