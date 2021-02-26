defmodule ProjectB.Workers.PrefixLoader do
  use GenServer

  @impl true
  def init(file_path) when is_binary(file_path) do
    prefixes =
      file_path
      |> Path.expand()
      |> File.read!()
      |> String.split()

    {:ok, prefixes}
  end

  @impl true
  def handle_call(:list_prefixes, _from, prefixes) do
    {:reply, prefixes, prefixes}
  end

  @spec start_link(String.t()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(file_path) when is_binary(file_path) do
    GenServer.start_link(__MODULE__, file_path, name: __MODULE__)
  end

  @spec list_prefixes :: list(String.t())
  def list_prefixes do
    GenServer.call(__MODULE__, :list_prefixes)
  end
end
