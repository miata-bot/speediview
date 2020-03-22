use Mix.Config

config :nerves_firmware_ssh,
  authorized_keys: [
    File.read!(Path.join(System.user_home!(), ".ssh/id_rsa.pub"))
  ]

config :speediview, SpeediViewUI.Layout, layout_file: "/root/layout.etf"

config :speediview, :viewport, %{
  name: :main_viewport,
  default_scene: {SpeediViewUI.Scene.Dash, []},
  size: {800, 480},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Nerves.Rpi
    },
    %{
      module: Scenic.Driver.Nerves.Touch,
      opts: [
        device: "FT5406 memory based driver",
        calibration: {{1, 0, 0}, {1, 0, 0}}
      ]
    }
  ]
}

config :nerves, :erlinit, hostname_pattern: "sv-%s"

import_config "config.network.exs"
