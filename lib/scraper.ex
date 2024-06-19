defmodule Rightmove.Scraper do
  alias Rightmove.Parser

  def scrape_links(url) do
    {:ok, %{body: body}} = url |> HTTPoison.get()

    html =
      body
      |> Floki.parse_document!()

    results = Parser.get_total_results(html)

    htmls =
      ([html] ++
         Enum.map(24..results//24, fn i ->
           url = url <> "&index=#{i}"

           case HTTPoison.get(url) do
             {:error, _} -> nil
             {:ok, %{body: body}} -> body |> Floki.parse_document!()
           end
         end))
      |> Enum.filter(&(&1 != nil))

    Task.async_stream(htmls, fn html ->
      Parser.find_properties(html)
    end)
    |> Stream.flat_map(fn {:ok, properties} -> properties end)
    |> Task.async_stream(
      fn %{} = map ->
        case HTTPoison.get(map[:link]) do
          {:error, _} ->
            nil

          {:ok, %{body: body}} ->
            page_html = body |> Floki.parse_document!()

            Map.merge(map, %{
              floorplan_img: Parser.find_floorplan(page_html),
              available: Parser.find_property_available_date(page_html),
              description: Parser.find_property_description(page_html)
            })
        end
      end,
      timeout: :infinity
    )
    |> Enum.filter(&(&1 != nil))
    |> Enum.map(fn {:ok, map} -> map end)
  end
end
