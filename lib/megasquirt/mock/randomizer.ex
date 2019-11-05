defmodule Megasquirt.Mock.Randomizer do
  def randomize(data) do
    randomize(data, data, [])
  end

  def randomize(data, orig, acc)

  def randomize([log | rest], orig, acc) do
    new_log =
      Map.new(log, fn {key, value} ->
        {key, randomize_value(value)}
      end)

    randomize(rest, orig, [new_log | acc])
  end

  def randomize([], orig, acc) do
    Enum.shuffle(orig ++ acc)
  end

  def randomize_value(input) do
    case :rand.uniform(2) do
      1 -> input + :rand.uniform()
      2 -> input - :rand.uniform()
    end
  end
end
