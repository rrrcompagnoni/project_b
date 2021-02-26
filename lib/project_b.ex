defmodule ProjectB do
  alias ProjectB.{
    BuildPhoneFailure,
    Phone,
    Workers.BusinessSector
  }

  @letters_are_not_allowed_message "Letters are not allowed."
  @space_after_plus_siginal_message "Space immediately after + is not allowed."
  @prefix_missing_message "Prefix not found."
  @wrong_number_length_message "The length of the number must be exactly 3 or more than 6 and less than 13."

  @spec prefixes(fun()) :: list(String.t())
  def prefixes(prefix_loader \\ fn -> ProjectB.Workers.PrefixLoader end) do
    prefix_loader.().list_prefixes()
  end

  @spec aggregate([String.t()], fun(), fun()) :: map()
  def aggregate(raw_numbers, phone_builder, business_sector_fetcher)
      when is_list(raw_numbers) and is_function(phone_builder) and
             is_function(business_sector_fetcher) do
    BusinessSector.map(raw_numbers, phone_builder, business_sector_fetcher)
    |> Enum.filter(fn
      %Phone{} -> true
      %BuildPhoneFailure{} -> false
    end)
    |> Enum.group_by(& &1.prefix)
    |> Enum.reduce(%{}, fn {key, values}, acc ->
      Map.merge(acc, %{key => Enum.frequencies_by(values, & &1.sector)})
    end)
  end

  @spec new_phone([{:number, String.t()} | {:prefix, String.t()} | {:raw_number, String.t()}]) ::
          ProjectB.Phone.t()
  def new_phone(attributes) when is_list(attributes) do
    Phone.new(attributes)
  end

  @spec set_phone_sector(Phone.t(), String.t()) :: Phone.t()
  def set_phone_sector(%Phone{sector: nil} = phone, sector) when is_binary(sector),
    do: Phone.set_sector(phone, sector)

  def set_phone_sector(%Phone{sector: phone_sector} = phone, sector)
      when is_binary(phone_sector) and is_binary(sector),
      do: phone

  @spec maybe_build_phone(String.t(), fun()) :: BuildPhoneFailure.t() | Phone.t()
  def maybe_build_phone(
        raw_number,
        prefixes \\ fn -> ProjectB.Workers.PrefixLoader.list_prefixes() end
      )
      when is_binary(raw_number) and is_function(prefixes) do
    with {:plus_signal_validation, false} <-
           {:plus_signal_validation, space_after_plus_siginal_is_present?(raw_number)},
         {:letter_presence_validation, false} <-
           {:letter_presence_validation, any_letter_present?(raw_number)},
         {:prefix_match, prefix} when is_binary(prefix) <-
           {:prefix_match, get_prefix(raw_number, prefixes)},
         number <- get_number(raw_number, prefix),
         {:number_length_validation, true} <-
           {:number_length_validation, valid_number_length?(prefix <> number)} do
      Phone.new(
        prefix: prefix,
        number: String.replace(number, ~r/\s/, ""),
        raw_number: raw_number
      )
    else
      {:letter_presence_validation, true} ->
        BuildPhoneFailure.new(reason: @letters_are_not_allowed_message)

      {:plus_signal_validation, true} ->
        BuildPhoneFailure.new(reason: @space_after_plus_siginal_message)

      {:prefix_match, nil} ->
        BuildPhoneFailure.new(reason: @prefix_missing_message)

      {:number_length_validation, false} ->
        BuildPhoneFailure.new(reason: @wrong_number_length_message)
    end
  end

  defp space_after_plus_siginal_is_present?(raw_number) do
    String.match?(raw_number, ~r/\+\s/)
  end

  defp any_letter_present?(raw_number) do
    String.match?(raw_number, ~r/[a-zA-Z]/)
  end

  defp valid_number_length?(number) do
    number_length = String.length(number)

    number_length == 3 or number_length in 7..12
  end

  defp get_prefix(raw_number, prefixes) when is_function(prefixes) do
    number = String.replace(raw_number, ~r/^\+||00/, "")

    Enum.find(prefixes.(), fn prefix ->
      number_size = byte_size(number)
      prefix_size = byte_size(prefix)

      if prefix_size <= number_size do
        prefix == binary_part(number, 0, prefix_size)
      else
        false
      end
    end)
  end

  defp get_number(raw_number, prefix) do
    [_, number] = String.split(raw_number, prefix, parts: 2)
    number
  end
end
