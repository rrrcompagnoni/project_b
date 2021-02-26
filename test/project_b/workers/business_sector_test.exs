defmodule ProjectB.Workers.BusinessSectorTest do
  use ExUnit.Case, async: true

  alias ProjectB.{
    BuildPhoneFailure,
    Phone,
    HTTPClients.BusinessSectorAPIFake,
    Workers.BusinessSector
  }

  @prefixes ["1", "2", "44"]

  setup do
    pid = self()

    %{
      phone_builder: fn raw_number ->
        send(pid, :phone_builder_called)

        ProjectB.maybe_build_phone(raw_number, fn -> @prefixes end)
      end,
      business_sector_fetcher: fn phone ->
        send(pid, :business_sector_fetcher_called)

        BusinessSectorAPIFake.fetch(phone)
      end
    }
  end

  describe "map/3" do
    test "dependencies call", %{
      phone_builder: phone_builder,
      business_sector_fetcher: business_sector_fetcher
    } do
      BusinessSector.map(
        ["+1983248", "001382355", "+147 8192", "+4439877"],
        phone_builder,
        business_sector_fetcher
      )

      assert_received :phone_builder_called
      assert_received :business_sector_fetcher_called
    end

    test "a buildable raw number", %{
      phone_builder: phone_builder,
      business_sector_fetcher: business_sector_fetcher
    } do
      assert [%Phone{prefix: "1", number: "983248", raw_number: "+1983248", sector: "Technology"}] =
               BusinessSector.map(["+1983248"], phone_builder, business_sector_fetcher)
    end

    test "a not buildable raw number", %{
      phone_builder: phone_builder,
      business_sector_fetcher: business_sector_fetcher
    } do
      assert [%BuildPhoneFailure{}] =
               BusinessSector.map([""], phone_builder, business_sector_fetcher)
    end
  end
end
