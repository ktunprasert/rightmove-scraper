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
  end
end

# https://www.rightmove.co.uk/property-to-rent/find.html?locationIdentifier=REGION%5E85362&maxBedrooms=2&minBedrooms=2&maxPrice=2800&propertyTypes=&includeLetAgreed=false&mustHave=&dontShow=&furnishTypes=furnished&keywords=
# https://www.rightmove.co.uk/property-to-rent/find.html?locationIdentifier=REGION^85362&maxBedrooms=2&minBedrooms=2&maxPrice=2800&index=24&propertyTypes=&includeLetAgreed=false&mustHave=&dontShow=&furnishTypes=furnished&keywords%3d

# https://www.rightmove.co.uk/property-to-rent/find.html?locationIdentifier=REGION^85362&maxBedrooms=2&minBedrooms=2&maxPrice=2800&index=24&propertyTypes=&includeLetAgreed=false&mustHave=&dontShow=&furnishTypes=furnished&keywords=
