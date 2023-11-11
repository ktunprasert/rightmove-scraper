defmodule Mix.Tasks.Gen.Md do
  @moduledoc "Geeenrates Markdown from properties"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    IO.puts("Beginning file write")

    json_filename = File.cwd!() <> ~s(/gen/properties.json)
    {:ok, json} = File.read(json_filename)
    properties = json |> Jason.decode!()

    filename = File.cwd!() <> ~s(/gen/properties.md)
    File.exists?(filename) && File.rm(filename)
    {:ok, file} = File.open(filename, [:append])

    properties
    |> Enum.each(fn property ->
      IO.binwrite(file, """
        ## #{property["address"]} #{property["title"]}

        <table>
        <thead>
        <tr>
          <th>Price</th>
          <th>Available</th>
          <th>Link</th>
          <th>Agency</th>
        </tr>
        </thead>

        <tbody>
        <tr>
          <td>#{property["price"]}</td>
          <td>#{property["available"]}</td>
          <td><a href="#{property["link"]}">Link</a></td>
          <td>#{property["agency"] |> String.split(",") |> Enum.at(0)}</td>
        </tr>
        </tbody>
        </table>

        <img src="#{property["floorplan_img"]}" alt="">

        #{property["description"]}
      """)
    end)

    IO.puts("Finished file write, wrote to #{filename}")
  end
end
