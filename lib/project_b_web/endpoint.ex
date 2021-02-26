defmodule ProjectBWeb.Endpoint do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  @business_sector_api Application.fetch_env!(:project_b, :business_sector_api)

  get "/ping" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!("pong"))
  end

  post "/aggregate" do
    %{"_json" => phone_numbers} = conn.body_params

    aggregation =
      ProjectB.aggregate(
        phone_numbers,
        fn raw_number -> ProjectB.maybe_build_phone(raw_number) end,
        fn phone -> @business_sector_api.fetch(phone) end
      )

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(201, Jason.encode!(aggregation))
  end
end
