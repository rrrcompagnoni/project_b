defmodule ProjectB.Workers.PrefixLoaderTest do
  use ExUnit.Case, async: true

  alias ProjectB.Workers.PrefixLoader

  test "it starts with the application" do
    pid = Process.whereis(PrefixLoader)

    assert is_pid(pid)
  end

  describe "list_prefixes" do
    test "the list of prefixes response" do
      # This list is defined by the application env config
      # check the config/test.exs under
      # the config key :prefixes_path
      assert ["1", "2", "44"] = PrefixLoader.list_prefixes()
    end
  end
end
