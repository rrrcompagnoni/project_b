defmodule ProjectBWeb.EndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias ProjectBWeb.Endpoint

  @opts Endpoint.init([])

  describe "POST /aggregate" do
    test "the success response" do
      phone_numbers = ["+1983248", "001382355", "+147 8192", "+4439877"]

      response =
        :post
        |> conn("/aggregate", Jason.encode!(phone_numbers))
        |> put_req_header("content-type", "application/json")
        |> Endpoint.call(@opts)

      assert response.status == 201

      assert Jason.decode!(response.resp_body) == %{
               "1" => %{"Clothing" => 1, "Technology" => 2},
               "44" => %{"Banking" => 1}
             }
    end

    test "an empty list of numbers" do
      phone_numbers = []

      response =
        :post
        |> conn("/aggregate", Jason.encode!(phone_numbers))
        |> put_req_header("content-type", "application/json")
        |> Endpoint.call(@opts)

      assert response.status == 201

      assert Jason.decode!(response.resp_body) == %{}
    end

    test "malformed numbers" do
      phone_numbers = ["1", "5"]

      response =
        :post
        |> conn("/aggregate", Jason.encode!(phone_numbers))
        |> put_req_header("content-type", "application/json")
        |> Endpoint.call(@opts)

      assert response.status == 201

      assert Jason.decode!(response.resp_body) == %{}
    end
  end
end
