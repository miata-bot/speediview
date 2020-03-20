defmodule SpeediView.PubSub do
  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args]}
    }
  end

  def start_link(_args) do
    Registry.start_link(keys: :duplicate, name: __MODULE__)
  end

  def subscribe(key) do
    {:ok, _} = Registry.register(__MODULE__, key, nil)
    :ok
  end

  def publish(key, value) do
    Registry.dispatch(__MODULE__, key, fn entries ->
      for {pid, _} <- entries, do: send(pid, {__MODULE__, key, value})
    end)
  end
end
