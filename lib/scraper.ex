defmodule Rightmove.Scraper do
  alias Rightmove.Parser

  def scrape_links(url) do
    {:ok, %{body: body}} = url |> HTTPoison.get()

    body
    |> Floki.parse_document!()
    |> Parser.find_properties()
  end
end
