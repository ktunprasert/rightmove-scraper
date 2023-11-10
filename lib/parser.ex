defmodule Rightmove.Parser do
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
          |> then(&"https://www.rightmove.co.uk#{&1}")
      }
    end
  end
end
