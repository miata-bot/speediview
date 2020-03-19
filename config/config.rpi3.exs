use Mix.Config

config :megasquirt, :viewport, %{
  name: :main_viewport,
  default_scene: {Megasquirt.Scene.Dash, []},
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

keys =
  [
    Path.join([System.user_home!(), ".ssh", "id_rsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ecdsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ed25519.pub"])
  ]
  |> Enum.filter(&File.exists?/1)

if keys == [],
  do:
    Mix.raise("""
    No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
    log into the Nerves device and update firmware on it using ssh.
    See your project's config.exs for this error message.
    """)

config :nerves_firmware_ssh,
  authorized_keys: Enum.map(keys, &File.read!/1)

config :vintage_net,
  regulatory_domain: "US",
  config: [
    {"usb0", %{type: VintageNet.Technology.Gadget}},
    {"eth0",
     %{
       type: VintageNet.Technology.Ethernet,
       ipv4: %{
         method: :dhcp
       }
     }},
    {"wlan0",
     %{
       type: VintageNet.Technology.WiFi
     }}
  ]
