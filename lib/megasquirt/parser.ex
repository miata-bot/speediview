defmodule Megasquirt.RealtimeParser do
  import Megasquirt.RealtimeParser.Tools

  def parse(data) do
    case data do
      <<
        field(secs, false, 16),
        field(pw1, false, 16),
        field(pw2, false, 16),
        field(rpm, false, 16),
        field(advance, true, 16),
        field(squirt, false, 8),
        field(engine, false, 8),
        field(afttgt1raw, false, 8),
        field(afttgt2raw, false, 8),
        field(wbo2_en1, false, 8),
        field(wbo2_en2, false, 8),
        field(barometer, true, 16),
        field(map, true, 16),
        field(mat, true, 16),
        field(coolant, true, 16),
        field(tps, true, 16),
        _::binary
      >> = data ->
        %{
          secs: secs,
          pw1: pw1 * 0.004,
          pw2: pw2 * 0.004,
          rpm: rpm * 1.000,
          advance: advance * 0.100,
          squirt: squirt,
          engine: engine,
          afttgt1raw: afttgt1raw,
          afttgt2raw: afttgt2raw,
          wbo2_en1: wbo2_en1,
          wbo2_en2: wbo2_en2,
          barometer: barometer * 0.100,
          map: map * 0.100,
          mat: mat * 0.100,
          coolant: coolant * 0.100,
          tps: tps * 0.100
        }

      _ ->
        :unknown
    end
  end
end
