use Mix.Config

config :megasquirt, :viewport, %{
  name: :main_viewport,
  # default_scene: {Megasquirt.Scene.Crosshair, nil},
  default_scene: {Megasquirt.Scene.SysInfo, [registry: MegasquirtData]},
  size: {800, 480},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      opts: [title: "MIX_TARGET=host, app = :megasquirt"]
    }
  ]
}
