defmodule ProjectB.HTTPClients.BusinessSectorAPIBehavior do
  alias ProjectB.Phone

  @callback fetch(Phone.t()) :: %{
              number: String.t(),
              sector: String.t()
            }
end
