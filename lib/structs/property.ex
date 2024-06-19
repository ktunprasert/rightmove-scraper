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
      "Added" => DateTime.now!("Etc/UTC") |> DateTime.to_string()
    }

    case map[:floorplan_img] do
      nil -> Map.delete(payload, "Floorplan Image")
      _ -> payload
    end
  end

  def from_map(%{} = map), do: struct(Rightmove.Property, map)
end
