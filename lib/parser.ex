defmodule Rightmove.Parser do
  def get_total_results(html) do
    html
    |> Floki.find(".searchHeader-resultCount")
    |> Floki.text()
    |> String.trim()
    |> String.replace(",", "")
    |> String.to_integer()
  end

  def find_properties(html) do
    for card <- html |> Floki.find(".propertyCard") do
      %{
        title: card |> Floki.find(".propertyCard-title") |> Floki.text() |> String.trim(),
        address: card |> Floki.find(".propertyCard-address") |> Floki.text(),
        price: card |> Floki.find(".propertyCard-priceValue") |> Floki.text(),
        link:
          card
          |> Floki.find(".propertyCard-link")
          |> Floki.attribute("href")
          |> List.first()
          |> then(&"https://www.rightmove.co.uk#{&1}"),
        agency:
          card
          |> Floki.find(".propertyCard-branchLogo-image")
          |> Floki.attribute("alt")
          |> List.first(),
        floorplan: card |> Floki.find(~s/a[title="Floor plan"]/) != []
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
    |> Floki.find(~s|h2:fl-contains("Property description") + div > div|)
    |> Floki.text()
    |> String.trim()
  end
end
