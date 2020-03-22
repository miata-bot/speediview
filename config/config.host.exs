use Mix.Config

config :speediview, :viewport, %{
  name: :main_viewport,
  default_scene: {SpeediViewUI.Scene.Dash, []},
  size: {800, 480},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      opts: [title: "MIX_TARGET=host, app = :speediview"]
    }
  ]
}
