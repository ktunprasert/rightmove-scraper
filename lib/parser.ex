defmodule Rightmove.Parser do
  def get_total_results(html) do
    html
    |> Floki.find("[class*=\"ResultsCount_resultsCount\"]")
    |> Floki.text()
    |> String.trim()
    |> String.replace(~r/[^\d]/, "")
    |> String.to_integer()
  end

  def find_properties(html) do
    for card <- html |> Floki.find("[class*=\"propertyCard-details\"]") do
      %{
        title: card |> Floki.find("[class*=\"PropertyInformation_propertyType\"]") |> List.first() |> Floki.text() |> String.trim(),
        address: card |> Floki.find("[class*=\"PropertyAddress_address\"]") |> List.first() |> Floki.text(),
        price: card |> Floki.find("[class*=\"PropertyPrice_price__\"]") |> List.first() |> Floki.text(),
        link:
          card
          |> Floki.find("a[class*=\"propertyCard-link\"]")
          |> Floki.attribute("href")
          |> List.first()
          |> then(&"https://www.rightmove.co.uk#{&1}"),
        agency:
          card
          |> Floki.find("img[class*=\"EstateAgent_estateAgentLogo\"]")
          |> Floki.attribute("alt")
          |> List.first(),
        floorplan: card |> Floki.find(~s/img[title="Property has a floorplan"]/) != []
      }
    end
    |> Enum.filter(fn property -> property[:address] !== "" end)
  end

  def find_floorplan(html) do
    with imgsrc when imgsrc != nil <-
           html
           |> Floki.find(~s{[href*="#/floorplan"] img})
           |> Floki.attribute("src")
           |> List.first() do
      String.replace(imgsrc, "_max_296x197", "")
    end
  end

  def find_property_available_date(html) do
    html |> Floki.find(~s|dt:fl-contains("Let available date:") + dd|) |> Floki.text()
  end

  def find_property_description(html) do
    html
    |> Floki.find(~s|h2:fl-contains("Description") + div > div|)
    |> Floki.text()
    |> String.trim()
  end
end
