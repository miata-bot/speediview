defmodule Megasquirt.MixProject do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"
  @app :megasquirt
  @all_targets [:rpi3]

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.7",
      target: @target,
      archives: [nerves_bootstrap: "~> 1.6"],
      deps_path: "deps/#{@target}",
      build_path: "_build/#{@target}",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env(), Mix.target()),
      build_embedded: true,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "democookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: false
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
      {:nerves, "~> 1.5", runtime: false},
      {:circuits_uart, "~> 1.3"},
      {:shoehorn, "~> 0.6"},
      {:ring_logger, "~> 0.6"},
      {:scenic, "~> 0.10"},
      {:scenic_fuel_gauge, "~> 0.1.0"}
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
      {:nerves_runtime, "~> 0.10"},
      {:scenic_driver_nerves_rpi, "~> 0.10"},
      {:scenic_driver_nerves_touch, "~> 0.10"},
      {:toolshed, "~> 0.2"},
      {:busybox, "~> 0.1", targets: @all_targets},
      {:vintage_net, "~> 0.6", targets: @all_targets},
      {:nerves_firmware_ssh, "~> 0.2", targets: @all_targets},
      {:nerves_time, "~> 0.2", targets: @all_targets},
      {:mdns_lite, "~> 0.4", targets: @all_targets}
    ] ++ system(target)
  end

  defp system("rpi3"), do: [{:nerves_system_rpi3a, "~> 1.9", runtime: false}]

  defp elixirc_paths(:test, :host) do
    ["./lib", "./test/support"]
  end

  defp elixirc_paths(_, :host) do
    ["./lib"]
  end

  defp elixirc_paths(_env, _target) do
    ["./lib", "./platform/"]
  end
end
