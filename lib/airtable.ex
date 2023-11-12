defmodule Rightmove.Airtable do
  @app_id "apphN4Py8FUdHSKDB"
  @table_id "tblZ7NbRj2KIUFa7V"

  @url "https://api.airtable.com/v0/#{@app_id}/#{@table_id}/"
  @auth_token Application.compile_env!(:rightmove_scraper, :auth_token)

  def create_record(payload) do
    %{status_code: status, body: body} =
      HTTPoison.post!(
        @url,
        payload |> Jason.encode!(),
        headers()
      )

    %{status_code: status, body: body}
  end

  def create_records(payload) do
    %{
      status_code: status,
      body: body
    } =
      HTTPoison.put!(
        @url,
        %{
          "performUpsert" => %{
            "fieldsToMergeOn" => ["URL"]
          },
          "records" => payload
        }
        |> Jason.encode!(),
        headers()
      )

    %{status_code: status, body: body}
  end

  def list_ids() do
    %{body: body} =
      HTTPoison.get!(
        @url <> "?fields[]=URL",
        headers()
      )

    body
    |> Jason.decode!()
    |> Map.get("records")
    |> Enum.map(&get_in(&1, ["fields", "URL"]))
  end

  defp headers() do
    [
      {"Authorization", "Bearer #{@auth_token}"},
      {"Content-Type", "application/json"}
    ]
  end
end
