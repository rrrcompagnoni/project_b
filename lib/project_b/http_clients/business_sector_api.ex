defmodule ProjectB.HTTPClients.BusinessSectorAPI do
  alias ProjectB.{
    HTTPClients.BusinessSectorAPIBehavior,
    Phone
  }

  @behaviour BusinessSectorAPIBehavior

  @impl true
  @spec fetch(Phone.t()) :: %{number: String.t(), sector: String.t()}
  def fetch(%Phone{sector: nil} = phone) do
    Finch.build(
      :get,
      URI.encode(
        "https://challenge-business-sector-api.meza.talkdeskstg.com/sector/#{phone.raw_number}"
      )
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
