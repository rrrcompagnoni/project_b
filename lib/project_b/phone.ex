defmodule ProjectB.Phone do
  @enforce_keys [:prefix, :number, :raw_number]

  defstruct prefix: "", number: "", raw_number: ""

  @type t() :: %__MODULE__{
          prefix: String.t(),
          number: String.t(),
          raw_number: String.t()
        }

  @spec new([{:prefix, String.t()}, {:number, String.t()}, {:raw_number, String.t()}]) ::
          ProjectB.Phone.t()
  def new(attributes) when is_list(attributes) do
    %__MODULE__{
      prefix: Access.get(attributes, :prefix, ""),
      number: Access.get(attributes, :number, ""),
      raw_number: Access.get(attributes, :raw_number, "")
    }
  end
end
