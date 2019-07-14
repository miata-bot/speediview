use Mix.Config

config :megasquirt, :viewport, %{
  name: :main_viewport,
  # default_scene: {Megasquirt.Scene.Crosshair, nil},
  default_scene: {Megasquirt.Scene.SysInfo, [registry: MegasquirtData]},
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

config :nerves_init_gadget,
  ifname: "eth0",
  address_method: :dhcpd,
  mdns_domain: "megasquirt.local",
  node_name: nil,
  node_host: :mdns_domain

config :logger, backends: [RingLogger]
