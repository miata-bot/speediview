defmodule SpeediView.Ini do
  @moduledoc "Represents a parsed ini file"

  alias SpeediView.Ini.{
    MegaTune,
    OutputChannels
  }

  defstruct [
    :output_channels,
    :decode_realtime_data,
    :realtime_data_byte_size,
    :mega_tune
  ]

  @type t() :: %__MODULE__{
          output_channels: [IniParser.record()],
          decode_realtime_data: OutputChannels.decode_realtime_data_fun(),
          realtime_data_byte_size: number(),
          mega_tune: MegaTune.t()
        }

  @doc "reads a file and destructures it into a map"
  @spec from_file(Path.t()) :: t()
  def from_file(filename) when is_binary(filename) do
    filename
    |> IniParser.parse_file()
    |> from_ini()
  end

  @doc "Loads a ini from memory"
  @spec from_string(binary()) :: t()
  def from_string(content) when is_binary(content) do
    content
    |> IniParser.parse_string()
    |> from_ini()
  end

  @doc false
  @spec from_ini(IniParser.t()) :: t()
  def from_ini(ini) do
    # deconstruct the expected fields.
    {_, output_channels} = List.keyfind(ini, "OutputChannels", 0)
    {_, mega_tune} = List.keyfind(ini, "MegaTune", 0)

    # this uses the output channels to generate a funcion.
    {decode_realtime_data_fun, realtime_data_byte_size} =
      OutputChannels.gen_decode_realtime_data(output_channels)

    %__MODULE__{
      output_channels: output_channels,
      decode_realtime_data: decode_realtime_data_fun,
      realtime_data_byte_size: realtime_data_byte_size,
      mega_tune: MegaTune.build_mega_tune(mega_tune, %MegaTune{})
    }
  end
end
