defmodule Megasquirt.Scenes.Settings.VintageNetBackend do
  @behaviour Megasquirt.Scenes.Settings.Backend

  def subscribe(_pid) do
    VintageNet.subscribe([])
  end
end