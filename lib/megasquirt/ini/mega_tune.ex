defmodule Megasquirt.Ini.MegaTune do
  @moduledoc """
  Required header on a tunerstudio ini
  """
  defstruct [
    :signature
  ]

  @typedoc "Describes the MegaTune structure"
  @type t :: %__MODULE__{
          signature: String.t()
        }

  @doc "Enumerates over a keyword list extracting out mega_tune key/values"
  @spec build_mega_tune([IniParser.record()], t()) :: t()
  def build_mega_tune([{"signature", [signature]} | rest], mega_tune) do
    build_mega_tune(rest, %{mega_tune | signature: String.trim(signature)})
  end

  def build_mega_tune([{_unknown_key, _unknown_value} | rest], mega_tune) do
    build_mega_tune(rest, mega_tune)
  end

  def build_mega_tune([], mega_tune), do: mega_tune
end
