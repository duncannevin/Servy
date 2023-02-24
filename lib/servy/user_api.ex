defmodule Servy.UserApi do

  @user_api_location "https://jsonplaceholder.typicode.com/users/"
  # @user_api_location "https://jsonplaceholder.typicode/users/"

  def query(user_id) do
    HTTPoison.get(@user_api_location <> user_id)
    |> handle_response
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}), do: {:ok, body |> Poison.Parser.parse!}

  defp handle_response({:ok, %{status_code: 404}}), do: {:error, "Not Found"}

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}), do: {:error, reason}

  def query_city(user_id) do
    case query(user_id) do
      {:ok, response_body} -> {:ok, get_in(response_body, ["address", "city"])}
      {:error, reason} -> {:error, reason}
    end
  end
end
