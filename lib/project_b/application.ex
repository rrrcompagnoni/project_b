defmodule ProjectB.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Supervisor.start_link(
      [
        {Plug.Cowboy,
         scheme: :http,
         plug: ProjectBWeb.Endpoint,
         port: Application.get_env(:project_b, :http_port)},
        {Task.Supervisor, name: ProjectB.TaskSupervisor},
        {Finch, name: ProjectB.Finch},
        {ProjectB.Workers.PrefixLoader, Application.get_env(:project_b, :prefixes_path)}
      ],
      strategy: :one_for_one,
      name: ProjectB.Supervisor
    )
  end
end
