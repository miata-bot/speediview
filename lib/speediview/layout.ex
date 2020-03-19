defmodule SpeediView.Layout do
  @moduledoc """
  Saves layouts to disk for next startup
  """

  @doc "Save the layout to disk"
  def save(layout) do
    # remote_reload(layout)
    File.write!(layout_file(), :erlang.term_to_binary(layout))
  end

  @doc "Lazily load the layout from disk"
  def load() do
    case File.read(layout_file()) do
      {:ok, bin} -> :erlang.binary_to_term(bin)
      _ -> %{}
    end
  end

  defp layout_file do
    Application.get_env(:speediview, __MODULE__, [])[:layout_file] || "layout.etf"
  end

  # if Mix.Project.config()[:target] == "host" do
  #   defp remote_reload(layout) do
  #     Node.stop()
  #     config = Mix.Project.config()
  #     cookie = config[:releases][config[:app]][:cookie]
  #     node_name = :"dash@sv-fd86.local"
  #     IO.puts "reloading layout on #{node_name}"
  #     {:ok, _} = Node.start(:"reload@0.0.0.0")
  #     Node.set_cookie(String.to_atom(cookie))
  #     true = Node.connect(node_name)
  #     :rpc.call(node_name, __MODULE__, :save, [layout])
  #   end
  # else
  #   defp remote_reload(_), do: :ok
  # end
end
