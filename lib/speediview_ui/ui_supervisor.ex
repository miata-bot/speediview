defmodule SpeediViewUI.UISupervisor do
  @moduledoc """
  Root supervisor for UI related stuff
  """

  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    main_viewport_config = Application.get_env(:speediview, :viewport)

    children = [
      {Scenic, viewports: [main_viewport_config]}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
