import Config

config :vintage_net,
  config: [
    {"wlan0",
     %{
       type: VintageNetWiFi,
       vintage_net_wifi: %{
         networks: [
           %{
             key_mgmt: :wpa_psk,
             ssid: "my_network_ssid",
             psk: "a_passphrase_or_psk"
           }
         ]
       }
     }},
    {"eth0", %{type: VintageNetEthernet}},
    {"usb0", %{type: VintageNetDirect}}
  ]
