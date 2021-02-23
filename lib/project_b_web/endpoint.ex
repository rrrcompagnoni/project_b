defmodule ProjectBWeb.Endpoint do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  get "/ping" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!("pong"))
  end
end
