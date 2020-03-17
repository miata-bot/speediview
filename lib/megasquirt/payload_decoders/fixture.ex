defmodule Megasquirt.FixturePayloadDecoder do
  @external_resource "fixture.ini"
  use Megasquirt.PayloadDecoder, ini: "fixture.ini"
end
