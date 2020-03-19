defmodule SpeediView.IniTest do
  use ExUnit.Case
  alias SpeediView.Ini

  test "creates a spec from an ini" do
    ini_string = """
    ; comment
    #set SOME_CONDITION
    #unset SOME_CONDITION
    ; #set SOME_OTHER_CONDITION
    [MegaTune]
      MTversion      = 2.25 ; MegaTune itself; needs to match exec version.
      signature      = "Sample format v0.1.0 "
    [header]
    some_key = value ; with an inline comment
    #if SOME_CONDITION
    condition =  true
    #elif SOME_OTHER_CONDITION
    condition = other
    #else
    condition = false
    #endif
    [OutputChannels]
      seconds = scalar, U16,   0, "s",   1.000, 0.0
      rpm     = scalar, U16,   2, "RPM", 1.000, 0.0
      advance = scalar, S16,   4, "deg", 0.100, 0.0
      squirt  = scalar, U08,   6, "bit", 1.000, 0.0
      firing1 = bits,   U08,   6, [0:0]
      firing2 = bits,   U08,   6, [1:1]
      sched1  = bits,   U08,   6, [2:2]
      inj1    = bits,   U08,   6, [3:3]
      sched2  = bits,   U08,   6, [4:4]
      inj2    = bits,   U08,   6, [5:5]
      extra   = bits,   U08,   6, [6:7]
      last    = scalar, U08,   10, "extra", 1.0, 0.0
    """

    %Ini{} = ini = Ini.from_string(ini_string)
    assert ini.mega_tune.signature == "Sample format v0.1.0"
    assert {"seconds", ["scalar", "U16", 0.0, "s", 1.0, 0.0]} in ini.output_channels
    assert ini.realtime_data_byte_size == 11.0

    assert %{
             seconds: 100.0,
             rpm: 950.0,
             advance: 35.0,
             squirt: 192.0,
             last: 150.0
           } =
             ini.decode_realtime_data.(<<
               # seconds
               100::unsigned-16,
               # rpm
               950::unsigned-16,
               # advance
               350::signed-16,
               # squirt struct
               0b11000000::unsigned-8,
               # 3 bytes of unused data
               0::unsigned-24,
               # one last thing
               150::unsigned-8
             >>)
  end
end
