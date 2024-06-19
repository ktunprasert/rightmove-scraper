defmodule Mix.Tasks.Create.Airtable do
  use Mix.Task

  alias Rightmove.{Property, Airtable}

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    IO.puts("Upserting records...")

    # Read from gen/properties.json
    properties = File.read!("gen/properties.json") |> Jason.decode!(keys: :atoms)

    records_payload =
      properties
      |> Enum.map(fn p ->
        p |> Property.from_map() |> Property.to_airtable_payload() |> then(&%{"fields" => &1})
      end)

    records_payload
    |> Stream.chunk_every(10)
    |> Task.async_stream(
      &Airtable.create_records/1,
      timeout: 15_000
    )
    |> Enum.to_list()
    |> IO.inspect()

    IO.puts("Done!")
  end
end
