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
               ProjectB.maybe_build_phone("189192879", @prefixes)
    end

    test "a number with a prefix not included into the allowed list" do
      assert %BuildPhoneFailure{reason: "Prefix not found."} ==
               ProjectB.maybe_build_phone("+19192879", @prefixes)
    end

    test "an empty prefix list" do
      assert %BuildPhoneFailure{reason: "You must provide a not empty prefix list."} ==
               ProjectB.maybe_build_phone("+19192879", [])
    end

    test "an empty number" do
      assert %BuildPhoneFailure{reason: "Prefix not found."} ==
               ProjectB.maybe_build_phone("", @prefixes)
    end

    test "a number with letters" do
      assert %BuildPhoneFailure{reason: "Letters are not allowed."} ==
               ProjectB.maybe_build_phone("191A92879", @prefixes)
    end

    test "a number with the + leading" do
      assert %Phone{prefix: "3", number: "89192879", raw_number: "+389192879"} =
               ProjectB.maybe_build_phone("+389192879", @prefixes)
    end

    test "a number with the 00 leading" do
      assert %Phone{prefix: "12", number: "9192879", raw_number: "00129192879"} =
               ProjectB.maybe_build_phone("00129192879", @prefixes)
    end

    test "a number with the + leading having a space immediately after" do
      assert %BuildPhoneFailure{reason: "Space immediately after + is not allowed."} ==
               ProjectB.maybe_build_phone("+ 191A92879", @prefixes)
    end

    test "a number with space not immediately after + leading" do
      assert %Phone{prefix: "3", number: "89192879", raw_number: "+3 89192879"} =
               ProjectB.maybe_build_phone("+3 89192879", @prefixes)
    end

    test "the boundaries for the number length" do
      assert %Phone{prefix: "18", number: "9", raw_number: "00189"} =
               ProjectB.maybe_build_phone("00189", @prefixes)

      assert %BuildPhoneFailure{
               reason:
                 "The length of the number must be exactly 3 or more than 6 and less than 13."
             } = ProjectB.maybe_build_phone("+189989", @prefixes)

      assert %Phone{prefix: "18", number: "99898", raw_number: "+1899898"} =
               ProjectB.maybe_build_phone("+1899898", @prefixes)

      assert %BuildPhoneFailure{
               reason:
                 "The length of the number must be exactly 3 or more than 6 and less than 13."
             } = ProjectB.maybe_build_phone("+1899891899898", @prefixes)
    end
  end
end
