defmodule Servy.Wildthings do
  alias Servy.Bear

  @db_path Path.expand("../../db", __DIR__)

  def list_bears() do
    {:ok, json} = @db_path
    |> Path.join("bears.json")
    |> File.read

    case Poison.decode!(json, %{as: %{"bears" => [%Bear{}]}}) do
      {:error, _} -> []
      %{"bears" => bears} -> cond do
        Mix.env == :test -> Enum.filter(bears, & &1.id < 11)
        true -> bears
      end
    end
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

  def create_bear(name, type) do
    existing_bears = list_bears()
    bear = %Bear{name: name, type: type, id: length(existing_bears) + 1}

    bears_json = %{bears: [bear | existing_bears]}
    |> Poison.encode!

    if Mix.env != :test do
      @db_path
      |> Path.join("bears.json")
      |> File.write!(bears_json, [:binary])
    end

    bear
  end

  def delete_bear(id) when is_integer(id) do
    updated_bears = list_bears()
    |> Enum.filter(& &1.id != id)

    bears_json = %{bears: updated_bears}
    |> Poison.encode!

    if Mix.env != :test do
      @db_path
      |> Path.join("bears.json")
      |> File.write!(bears_json, [:binary])
    end

    updated_bears
  end

  def delete_bear(id) when is_binary(id) do
    cond do
      String.match?(id, ~r/^\d+$/) -> id |> String.to_integer |> delete_bear
      true -> nil
    end
  end
end
