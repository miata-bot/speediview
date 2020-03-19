defmodule SpeediView.Platform.Distribution do
  @moduledoc """
  Starts erlang distrution
  """
  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_distribution, args}
    }
  end

  def start_distribution() do
    _ = :os.cmd('epmd -daemon')
    Node.start(String.to_atom("dash@#{:inet.gethostname() |> elem(1)}.local"))
  end
end