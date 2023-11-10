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
        "title" => card |> Floki.find(".propertyCard-title") |> Floki.text() |> String.trim(),
        "address" => card |> Floki.find(".propertyCard-address") |> Floki.text(),
        "price" => card |> Floki.find(".propertyCard-priceValue") |> Floki.text(),
        "link" =>
          card
          |> Floki.find(".propertyCard-link")
          |> Floki.attribute("href")
          |> List.first()
          |> then(&"https://www.rightmove.co.uk#{&1}"),
        "agency" =>
          card
          |> Floki.find(".propertyCard-branchLogo-image")
          |> Floki.attribute("alt")
          |> List.first(),
        "floorplan" => card |> Floki.find("a[title=\"Floor plan\"]") != []
      }
    end
    |> Enum.filter(fn property -> property["address"] end)
  end
end
