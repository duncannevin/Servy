defmodule Servy.Wildthings do
  alias Servy.Bear

  def list_bears do
    [
      %Bear{id: 1, name: "Teddy", type: "Brown", hibernating: true},
      %Bear{id: 2, name: "Smokey", type: "black"},
      %Bear{id: 3, name: "Paddington", type: "Brown"},
      %Bear{id: 4, name: "Scarface", type: "Grizzly", hibernating: true},
      %Bear{id: 5, name: "Snow", type: "Polar"},
      %Bear{id: 6, name: "Brutus", type: "Grizzly"},
      %Bear{id: 7, name: "Rosie", type: "Black", hibernating: true},
      %Bear{id: 8, name: "Roscoe", type: "Panda"},
      %Bear{id: 9, name: "Iceman", type: "Polar", hibernating: true},
      %Bear{id: 10, name: "Kenai", type: "Grizzly"},
    ]
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn b -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    cond do
      String.match?(id, ~r/^\d+$/) -> id |> String.to_integer |> get_bear
      true -> nil
    end
  end

  def delete_bear(id) when is_integer(id) do
    list_bears()
    |> Enum.filter(& &1.id != id)
  end

  def delete_bear(id) when is_binary(id) do
    cond do
      String.match?(id, ~r/^\d+$/) -> list_bears()
      |> Enum.filter(& &1.id != id)
      true -> []
    end
  end
end
