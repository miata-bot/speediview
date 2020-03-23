defmodule IniParserTest do
  use ExUnit.Case

  test "parses ini" do
    ini =
      IniParser.parse_string("""
      [header1]
      key1 = value1
      [header2]
      key2 = value2
      [header3]
      key3 = 6.9
      """)

    assert match?(
             [
               {"header1", [{"key1", ["value1"]}]},
               {"header2", [{"key2", ["value2"]}]},
               {"header3", [{"key3", [6.9]}]}
             ],
             ini
           )
  end

  test "preprocessor" do
    ini =
      IniParser.parse_string("""
      #define HELLO_WORLD = "HELLO", "WORLD"
      #define NUMBER = 1.5
      [header1]
      hello_world = $HELLO_WORLD
      number_value = $NUMBER
      """)

    assert match?(
             [
               {"header1",
                [
                  {"hello_world", ["HELLO", "WORLD"]},
                  {"number_value", [1.5]}
                ]}
             ],
             ini
           )
  end

  test "binary string" do
    ini =
      IniParser.parse_string("""
      [header]
      binary_str = "T\x01\xFC\x00\x01\xFC"
      """)

    assert match?(
             [
               {"header",
                [
                  {"binary_str", [<<"T", 0x01, 0xFC, 0x00, 0x01, 0xFC>>]}
                ]}
             ],
             ini
           )
  end
end
