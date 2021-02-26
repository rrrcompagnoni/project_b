defmodule ProjectB.Phone do
  @enforce_keys [:prefix, :number, :raw_number]

  defstruct prefix: "", number: "", raw_number: "", sector: nil

  @type t() :: %__MODULE__{
          prefix: String.t(),
          number: String.t(),
          raw_number: String.t(),
          sector: nil | String.t()
        }

  @spec new([{:number, String.t()} | {:prefix, String.t()} | {:raw_number, String.t()}]) ::
          __MODULE__.t()
  def new(attributes) when is_list(attributes) do
    %__MODULE__{
      prefix: Access.get(attributes, :prefix, ""),
      number: Access.get(attributes, :number, ""),
      raw_number: Access.get(attributes, :raw_number, "")
    }
  end

  @spec set_sector(__MODULE__.t(), String.t()) :: __MODULE__.t()
  def set_sector(%__MODULE__{} = phone, sector) when is_binary(sector) do
    %{phone | sector: sector}
  end
end
