defmodule Megasquirt.MixProject do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"

  def project do
    [
      app: :megasquirt,
      version: "0.1.0",
      elixir: "~> 1.7",
      target: @target,
      archives: [nerves_bootstrap: "~> 1.0"],
      deps_path: "deps/#{@target}",
      build_path: "_build/#{@target}",
      lockfile: "mix.lock.#{@target}",
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps()
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Megasquirt.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nerves, "~> 1.4.5", runtime: false},
      {:elixir_make, "0.5.0", runtime: false},
      {:circuits_uart, "~> 1.3"},
      {:shoehorn, "~> 0.5.0"},
      {:ring_logger, "~> 0.6"},
      {:scenic, "~> 0.10"},
      {:scenic_sensor, "~> 0.7"}
    ] ++ deps(@target)
  end

  # Specify target specific dependencies
  defp deps("host") do
    [
      {:scenic_driver_glfw, "~> 0.10"}
    ]
  end

  defp deps(target) do
    [
      {:nerves_runtime, "~> 0.9"},
      {:scenic_driver_nerves_rpi, "~> 0.10"},
      {:scenic_driver_nerves_touch, "~> 0.10"},
      {:nerves_init_gadget, "~> 0.6"}
    ] ++ system(target)
  end

  defp system("rpi3"), do: [{:farmbot_system_rpi3, "~> 1.7.2-farmbot.2", runtime: false}]
end
