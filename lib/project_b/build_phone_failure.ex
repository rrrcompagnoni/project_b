defmodule ProjectB.BuildPhoneFailure do
  @enforce_keys :reason

  defstruct reason: ""

  @type t() :: %__MODULE__{
          reason: String.t()
        }

  @spec new([{:reason, String.t()}]) :: __MODULE__.t()
  def new(attributes) when is_list(attributes) do
    %__MODULE__{
      reason: Access.get(attributes, :reason)
    }
  end
end
