defmodule ProjectBTest do
  use ExUnit.Case, async: true

  alias ProjectB.{
    BuildPhoneFailure,
    Phone
  }

  @prefixes ["12", "18", "3"]

  describe "maybe_build_phone/2" do
    test "a number with a prefix included into the allowed list" do
      assert %Phone{prefix: "18", number: "9192879", raw_number: "189192879"} =
               ProjectB.maybe_build_phone("189192879", fn -> @prefixes end)
    end

    test "a number with a prefix not included into the allowed list" do
      assert %BuildPhoneFailure{reason: "Prefix not found."} ==
               ProjectB.maybe_build_phone("+19192879", fn -> @prefixes end)
    end

    test "an empty prefix list" do
      assert %BuildPhoneFailure{reason: "Prefix not found."} ==
               ProjectB.maybe_build_phone("+19192879", fn -> [] end)
    end

    test "an empty number" do
      assert %BuildPhoneFailure{reason: "Prefix not found."} ==
               ProjectB.maybe_build_phone("", fn -> @prefixes end)
    end

    test "a number with letters" do
      assert %BuildPhoneFailure{reason: "Letters are not allowed."} ==
               ProjectB.maybe_build_phone("191A92879", fn -> @prefixes end)
    end

    test "a number with the + leading" do
      assert %Phone{prefix: "3", number: "89192879", raw_number: "+389192879"} =
               ProjectB.maybe_build_phone("+389192879", fn -> @prefixes end)
    end

    test "a number with the 00 leading" do
      assert %Phone{prefix: "12", number: "9192879", raw_number: "00129192879"} =
               ProjectB.maybe_build_phone("00129192879", fn -> @prefixes end)
    end

    test "a number with the + leading having a space immediately after" do
      assert %BuildPhoneFailure{reason: "Space immediately after + is not allowed."} ==
               ProjectB.maybe_build_phone("+ 191A92879", fn -> @prefixes end)
    end

    test "a number with space not immediately after + leading" do
      assert %Phone{prefix: "3", number: "89192879", raw_number: "+3 89192879"} =
               ProjectB.maybe_build_phone("+3 89192879", fn -> @prefixes end)
    end

    test "the boundaries for the number length" do
      assert %Phone{prefix: "18", number: "9", raw_number: "00189"} =
               ProjectB.maybe_build_phone("00189", fn -> @prefixes end)

      assert %BuildPhoneFailure{
               reason:
                 "The length of the number must be exactly 3 or more than 6 and less than 13."
             } = ProjectB.maybe_build_phone("+189989", fn -> @prefixes end)

      assert %Phone{prefix: "18", number: "99898", raw_number: "+1899898"} =
               ProjectB.maybe_build_phone("+1899898", fn -> @prefixes end)

      assert %BuildPhoneFailure{
               reason:
                 "The length of the number must be exactly 3 or more than 6 and less than 13."
             } = ProjectB.maybe_build_phone("+1899891899898", fn -> @prefixes end)
    end
  end

  describe "aggregate/3" do
    test "a list of phones" do
      prefixes = ["1", "2", "44"]
      raw_phones = ["+1983248", "001382355", "+147 8192", "+4439877"]

      phone_builder = fn raw_number ->
        ProjectB.maybe_build_phone(raw_number, fn -> prefixes end)
      end

      business_sector_fetcher = fn phone ->
        ProjectB.HTTPClients.BusinessSectorAPIFake.fetch(phone)
      end

      assert %{
               "1" => %{
                 "Technology" => 2,
                 "Clothing" => 1
               },
               "44" => %{
                 "Banking" => 1
               }
             } = ProjectB.aggregate(raw_phones, phone_builder, business_sector_fetcher)
    end
  end

  describe "prefixes/1" do
    test "the prefix loader call" do
      pid = self()

      prefix_loader = fn ->
        send(pid, :prefix_loader_called)

        ProjectB.Workers.PrefixLoader
      end

      ProjectB.prefixes(prefix_loader)

      assert_received :prefix_loader_called
    end
  end

  describe "set_phone_sector/1" do
    test "a phone missing sector" do
      phone = ProjectB.new_phone(prefix: "1", number: "96988", raw_number: "+196988")

      assert %Phone{prefix: "1", number: "96988", raw_number: "+196988", sector: "Technology"} =
               ProjectB.set_phone_sector(phone, "Technology")
    end

    test "a phone with a sector already set" do
      phone =
        ProjectB.new_phone(prefix: "1", number: "96988", raw_number: "+196988")
        |> ProjectB.set_phone_sector("Technology")

      assert %Phone{prefix: "1", number: "96988", raw_number: "+196988", sector: "Technology"} =
               ProjectB.set_phone_sector(phone, "Banking")
    end
  end
end
