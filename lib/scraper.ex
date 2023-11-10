defmodule Rightmove.Scraper do
  alias Rightmove.Parser

  def scrape_links(url) do
    {:ok, %{body: body}} = url |> HTTPoison.get()

    html =
      body
      |> Floki.parse_document!()

    results = Parser.get_total_results(html)

    htmls =
      [html] ++
        Enum.map(0..results//24, fn i ->
          url = url <> "&index=#{i}"

          url |> HTTPoison.get!() |> Map.get(:body) |> Floki.parse_document!()
        end)

    Task.async_stream(htmls, fn html ->
      Parser.find_properties(html)
    end)
    |> Enum.flat_map(fn {:ok, properties} -> properties end)
    |> Task.async_stream(fn %{} = map ->
      page_html = map["link"] |> HTTPoison.get!() |> Map.get(:body) |> Floki.parse_document!()

      %{map | floorplan_img: Parser.find_floorplan(page_html)}
    end)
    |> Enum.to_list()
  end
end
