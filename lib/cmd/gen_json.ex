defmodule Mix.Tasks.Gen.Json do
  @moduledoc "Generates JSON from properties"

  use Mix.Task

  alias Rightmove.Scraper

  @url "https://www.rightmove.co.uk/property-to-rent/find.html?locationIdentifier=REGION^85362&maxBedrooms=2&minBedrooms=4&maxPrice=3300&propertyTypes&includeLetAgreed=false&mustHave&dontShow&furnishTypes=furnished&keywords"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    IO.puts("Beginning to scrape")

    Scraper.scrape_links(@url)

    filename = File.cwd!() <> ~s(/gen/properties.json)

    {:ok, file} = File.open(filename, [:write])

    IO.binwrite(file, Scraper.scrape_links(@url) |> Jason.encode!())

    IO.puts("Finished scraping wrote to #{filename}")
  end
end
