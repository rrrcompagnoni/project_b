defmodule ProjectB do
  alias ProjectB.{
    BuildPhoneFailure,
    Phone
  }

  @letters_are_not_allowed_message "Letters are not allowed."
  @space_after_plus_siginal_message "Space immediately after + is not allowed."
  @prefix_missing_message "Prefix not found."
  @wrong_number_length_message "The length of the number must be exactly 3 or more than 6 and less than 13."
  @empty_prefix_list_message "You must provide a not empty prefix list."

  @spec maybe_build_phone(String.t(), list()) :: BuildPhoneFailure.t() | Phone.t()
  def maybe_build_phone(_, []), do: BuildPhoneFailure.new(reason: @empty_prefix_list_message)

  def maybe_build_phone(raw_number, prefixes)
      when is_binary(raw_number) and is_list(prefixes) do
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

  defp get_prefix(raw_number, prefixes) do
    number = String.replace(raw_number, ~r/^\+||00/, "")

    Enum.find(prefixes, fn prefix ->
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
