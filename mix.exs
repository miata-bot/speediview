defmodule SpeediView.MixProject do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"
  @app :speediview
  @all_targets [:rpi3, :rpi3a]

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.7",
      target: @target,
      archives: [nerves_bootstrap: "~> 1.7"],
      deps_path: "deps/#{@target}",
      build_path: "_build/#{@target}",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env(), Mix.target()),
      build_embedded: true,
      aliases: [loadconfig: [&bootstrap/1], test: ["test --no-start"]],
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
      mod: {SpeediView.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps() do
    [
      {:nerves, "~> 1.6", runtime: false},
      {:circuits_uart, "~> 1.4"},
      {:shoehorn, "~> 0.6"},
      {:ring_logger, "~> 0.6"},
      {:scenic, "~> 0.10"},
      {:scenic_driver_glfw, "~> 0.10", targets: :host},
      {:nerves_runtime, "~> 0.10", targets: @all_targets},
      {:scenic_driver_nerves_rpi, "~> 0.10", targets: @all_targets},
      {:scenic_driver_nerves_touch, "~> 0.10", targets: @all_targets},
      {:toolshed, "~> 0.2", tragets: @all_targets},
      {:nerves_pack, "~> 0.3.0", targets: @all_targets},
      {:nerves_time, "~> 0.2", targets: @all_targets},
      {:vintage_net, "~> 0.6", targets: @all_targets},
      {:vintage_net_wifi, "~> 0.7.0", targets: @all_targets},
      {:vintage_net_ethernet, "~> 0.7.0", targets: @all_targets},
      {:vintage_net_direct, "~> 0.7.0", targets: @all_targets},
      {:nerves_system_rpi3, "~> 1.11", runtime: false, targets: :rpi3},
      {:nerves_system_rpi3a, "~> 1.11", runtime: false, targets: :rpi3a}
    ]
  end

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
