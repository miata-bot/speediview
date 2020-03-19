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
end
