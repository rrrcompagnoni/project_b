defmodule ProjectB.Workers.BusinessSector do
  alias ProjectB.{
    BuildPhoneFailure,
    Phone
  }

  @spec map(list(String.t()), fun(), fun()) :: list(Phone)
  def map(raw_phones, phone_builder, business_sector_fetcher)
      when is_list(raw_phones) and is_function(phone_builder) and
             is_function(business_sector_fetcher) do
    Enum.map(raw_phones, fn raw_phone ->
      Task.Supervisor.async(ProjectB.TaskSupervisor, fn ->
        maybe_build_and_set_sector(raw_phone, phone_builder, business_sector_fetcher)
      end)
    end)
    |> Task.await_many()
  end

  defp maybe_build_and_set_sector(raw_phone, phone_builder, business_sector_fetcher) do
    case phone_builder.(raw_phone) do
      %Phone{} = phone ->
        ProjectB.set_phone_sector(phone, fetch_sector(phone, business_sector_fetcher))

      %BuildPhoneFailure{} = failure ->
        failure
    end
  end

  defp fetch_sector(phone, business_sector_fetcher) do
    phone
    |> business_sector_fetcher.()
    |> Map.fetch!(:sector)
  end
end
