defmodule ProjectB.HTTPClients.BusinessSectorAPIFake do
  alias ProjectB.{
    HTTPClients.BusinessSectorAPIBehavior,
    Phone
  }

  @behaviour BusinessSectorAPIBehavior

  @impl true
  @spec fetch(Phone.t()) :: %{number: String.t(), sector: String.t()}
  def fetch(%Phone{prefix: "1", number: "983248", raw_number: "+1983248"}) do
    %{
      number: "+1983248",
      sector: "Technology"
    }
  end

  def fetch(%Phone{prefix: "1", number: "382355", raw_number: "001382355"}) do
    %{
      number: "+1382355",
      sector: "Technology"
    }
  end

  def fetch(%Phone{prefix: "1", number: "478192", raw_number: "+147 8192"}) do
    %{
      number: "+1478192",
      sector: "Clothing"
    }
  end

  def fetch(%Phone{prefix: "44", number: "39877", raw_number: "+4439877"}) do
    %{
      number: "+4439877",
      sector: "Banking"
    }
  end
end
