defmodule Babble do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    time_source = Application.get_env :babble, :time_source, Babble.Time.RealTime

    children = [
      supervisor(Babble.Registry, []),
      supervisor(Babble.Time, [time_source]),

      supervisor(Babble.Repo, []),
      supervisor(Babble.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: Babble.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Babble.Endpoint.config_change(changed, removed)
    :ok
  end
end
