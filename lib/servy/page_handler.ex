defmodule Servy.PageHandler do
  @moduledoc """
  Handles getting the page files.
  """

  @pages_path Path.expand("../../pages", __DIR__)

  def get_page(page_name) do
    @pages_path
      |> Path.join(page_name <> ".html")
      |> File.read
  end
end
