defmodule Mix.Tasks.Reload do
  @moduledoc """
  Reloads an application on a remote noe
  """
  use Mix.Task

  @switches [
    app: :keep,
    module: :keep
  ]

  def run(args) do
    config = Mix.Project.config()
    cookie = config[:releases][config[:app]][:cookie]
    {opts, args} = OptionParser.parse!(args, strict: @switches)
    [node_name | _] = args
    node_name = String.to_atom(node_name)

    mods = get_mods(opts, config)
    {:ok, _} = Node.start(:"reload@0.0.0.0")
    Node.set_cookie(String.to_atom(cookie))
    true = Node.connect(node_name)

    for module <- mods do
      {:ok, [{^node_name, :loaded, ^module}]} = IEx.Helpers.nl([node_name], module)
    end

    :rpc.call(node_name, Application, :stop, [:speediview])
    :rpc.call(node_name, Application, :start, [:speediview])
  end

  defp get_mods(opts, config) do
    case Keyword.get_values(opts, :module) do
      [_ | _] = mods ->
        Enum.map(mods, fn mod ->
          mod = Module.concat("Elixir", mod)
          Code.ensure_loaded?(mod)
          mod
        end)

      [] ->
        get_apps(opts, config)
    end
  end

  defp get_apps(opts, config) do
    apps =
      case Keyword.get_values(opts, :app) do
        [] -> [config[:app]]
        [_ | _] = apps -> Enum.map(apps, &String.to_atom/1)
      end

    Enum.reduce(apps, [], fn app, mods ->
      Application.load(app)
      {:ok, more_mods} = :application.get_key(app, :modules)
      mods ++ more_mods
    end)
  end
end
