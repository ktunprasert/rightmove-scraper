defmodule Rightmove.Property do
  defstruct [
    :title,
    :address,
    :price,
    :link,
    :agency,
    :floorplan,
    :floorplan_img,
    :available,
    :description
  ]

  # Field mappings
  # URL: URL
  # Address: A Single line text
  # Agency: A Single line text
  # Available Date: A Single line text
  # Description: Long text
  # Floorplan Image: Attachment
  # Price: Currency
  def to_airtable_payload(%__MODULE__{} = struct) do
    map = struct |> Map.from_struct()

    payload = %{
      "URL" => map[:link],
      "Address" => map[:address],
      "Agency" => map[:agency],
      "Available Date" => map[:available],
      "Description" => map[:description],
      "Floorplan Image" => [
        %{
          "url" => map[:floorplan_img]
        }
      ],
      "Price" => map[:price] |> String.replace(~r/\D/, "") |> String.to_integer(),
      "Added" => DateTime.now!("Europe/London") |> DateTime.to_string()
    }

    if map[:floorplan_img] == nil do
      Map.delete(payload, "Floorplan Image")
    else
      payload
    end
  end

  def from_map(%{} = map), do: struct(Rightmove.Property, map)
end
