defmodule ProjectB.HTTPClients.BusinessSectorAPI do
  alias ProjectB.{
    HTTPClients.BusinessSectorAPIBehavior,
    Phone
  }

  @behaviour BusinessSectorAPIBehavior

  @endpoint Application.compile_env!(:project_b, :business_sector_endpoint)

  @impl true
  @spec fetch(Phone.t()) :: %{number: String.t(), sector: String.t()}
  def fetch(%Phone{sector: nil} = phone) do
    Finch.build(
      :get,
      URI.encode("#{@endpoint}/#{phone.raw_number}")
    )
    |> Finch.request(ProjectB.Finch)
    |> case do
      {:ok, %Finch.Response{:body => raw_body}} ->
        raw_body
        |> Jason.decode!()
        |> Enum.reduce(%{}, fn {key, value}, acc ->
          Map.merge(acc, %{String.to_atom(key) => value})
        end)
    end
  end
end
