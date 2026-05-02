defmodule Mix.Tasks.Gen.Json do
  @moduledoc "Generates JSON from properties"

  use Mix.Task

  alias Rightmove.Scraper

  @url "https://www.rightmove.co.uk/property-to-rent/find.html?minBedrooms=2&maxBedrooms=4&sortType=6&includeLetAgreed=false&areaSizeUnit=sqft&channel=RENT&index=0&maxPrice=2250&locationIdentifier=STATION%5E10286&transactionType=LETTING&displayLocationIdentifier=undefined&furnishTypes=furnished&dontShow=houseShare&radius=1.0"
  @api "https://www.rightmove.co.uk/api/property-search/listing/search?minBedrooms=2&maxBedrooms=4&sortType=6&includeLetAgreed=false&areaSizeUnit=sqft&viewType=MAP&channel=RENT&index=0&maxPrice=2250&locationIdentifier=STATION%5E10286&numberOfPropertiesPerPage=95&transactionType=LETTING&displayLocationIdentifier=undefined&furnishTypes=furnished&dontShow=houseShare&radius=1.0"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    IO.puts("Beginning to scrape")

    filename = File.cwd!() <> ~s(/gen/properties.json)

    {:ok, file} = File.open(filename, [:write])

    IO.binwrite(file, Scraper.scrape_links(@url, @api) |> Jason.encode!())

    IO.puts("Finished scraping wrote to #{filename}")
  end
end
