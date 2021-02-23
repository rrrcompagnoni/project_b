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
         port: Application.get_env(:project_b, :http_port)}
      ],
      strategy: :one_for_one,
      name: ProjectB.Supervisor
    )
  end
end
